#!/bin/bash

CURR=$(
  cd $(dirname $0)
  pwd
)

CONFIG_FILE=$CURR/config/config.yml
PROGRAMS_FILE=$CURR/config/programs.yml
PROGRAM_NAME=$(head -n 1 ${PROGRAMS_FILE} | awk '{print $3}')
GOSUV_PID="${CURR}/.gosuv.pid"
GOSUV_SOCK="${CURR}/.gosuv.sock"
GOSUV_FILE="${CURR}/bin/gosuv"
GOSUV="${GOSUV_FILE} -c ${CONFIG_FILE}"

#启动时，会通过调用该端口的/actuator/health请求查看服务状态
JAR_PORT=""
RUN_LOG_DIR="${CURR}/log/run"

START_MAX_WAIT=30
START_SLEEP_SECONDS=1
CHECK_URL="http://127.0.0.1:${JAR_PORT}/actuator/prometheus"
SHOW_CHECK_RESULT=1

function errLog() {
    local ttime=`date +%Y-%m-%d' '%H:%M:%S.%N | cut -b 1-23`
    echo " [ERR] [${ttime}] $1"
    exit 1
}

function infoLog() {
    local ttime=`date +%Y-%m-%d' '%H:%M:%S.%N | cut -b 1-23`
    echo " [INFO] [${ttime}] $1"
}

function warnLog() {
    local ttime=`date +%Y-%m-%d' '%H:%M:%S.%N | cut -b 1-23`
    echo " [WARN] [${ttime}] $1"
}

function processLog() {
    local ttime=`date +%Y-%m-%d' '%H:%M:%S.%N | cut -b 1-23`
    echo "        [${ttime}] -> $1"
}

function checkScript(){
    if [[ -z "${JAR_PORT}" ]];then
        errLog "you must set JAR_PORT in this script"
    fi
    if [[ ! -f ${CONFIG_FILE} ]];then
        errLog "find no ${CONFIG_FILE}"
    fi
    if [[ ! -f ${GOSUV_FILE} ]];then
        errLog "find no ${GOSUV_FILE}"
    fi
    if [[ ! -f ${PROGRAMS_FILE} ]];then
        errLog "find no ${PROGRAMS_FILE}"
    fi
    if [[ ! -d ${RUN_LOG_DIR} ]]; then
        mkdir -p ${RUN_LOG_DIR}
    fi
    if [ x"${PROGRAM_NAME}" == "x" ]; then
        errLog "run script failed, find no program name in ${PROGRAMS_FILE}"
    fi
}

function checkGosuvPID() {
    if [[ ! -f ${GOSUV_PID} ]];then
        return
    fi
    read pid < ${GOSUV_PID}
    local process=$(ps ax | grep ${pid} | grep -v grep | awk '{print $1}')
    if [[ -z ${process} ]];then
        infoLog "cannot find gosuv process, delete gosuv.pid and gosuv.sock"
        rm ${GOSUV_PID}
        rm ${GOSUV_SOCK}
    fi
}

function checkStartRunningStatus(){
    local status="stopped"
    local startTime=$(date +%s)
    local endTime=0
    local costTime=0
    for i in $(seq 1 ${START_MAX_WAIT}); do
        local curlStartTime=$(date +%s)
        #status=$(curl -s ${CHECK_URL})
        status=$(curl -I -m 10 -o /dev/null -s -w %{http_code} ${CHECK_URL})
        local curlEndTime=$(date +%s)
        local curlCostTime=$[ ${curlEndTime}-${curlStartTime} ]
        if [ x"${SHOW_CHECK_RESULT}" == "x1" ];then
            processLog "check $i, curl ${CHECK_URL} cost:${curlCostTime} s result: ${status}"
        else
            processLog "check $i, curl ${CHECK_URL} cost:${curlCostTime} s"
        fi
        if [ x"${status}" == "x200" ]; then
            endTime=$(date +%s)
            costTime=$[ ${endTime}-${startTime} ]
            processLog "check health ok, cost: ${costTime} s"
            return
        fi
        processLog "sleep wait ${START_SLEEP_SECONDS} s"
        sleep ${START_SLEEP_SECONDS}
    done
    endTime=$(date +%s)
    costTime=$[ ${endTime}-${startTime} ]
    errLog "start failed, retry count: ${START_MAX_WAIT}, cost: ${costTime} s"
}

function start() {
    local command=`cat ${PROGRAMS_FILE} | grep command`
    infoLog "start java, ${GOSUV_FILE}, ${PROGRAM_NAME}"
    infoLog "gosuv${command}"
    start_gosuv
    checkStartRunningStatus
    infoLog "start ok"
}

function stop() {
    infoLog "stop java, ${PROGRAM_NAME}"
    stop_gosuv
    infoLog "stop ok"
}

function restart() {
    stop
    start
}

function reload() {
    infoLog "reload gosuv server"
    ${GOSUV} reload || exit 1
    checkStartRunningStatus
    infoLog "reload gosuv server ok"
}

function stop_gosuv(){
    infoLog "stop gosuv server"
    ${GOSUV} shutdown
    if [ $? -ne 0  ]; then
       rm -f .gosuv*
       #解决gosuv反复stop异常退出的bug
       warnLog "gosuv must be stopped some time ago, so, it's ok."
       return
    fi
    infoLog "stop gosuv server ok"
}

function start_gosuv(){
    infoLog "start gosuv server"
    ${GOSUV} start-server || exit 1
    infoLog "start gosuv server ok"
}

function restart_gosuv(){
    infoLog "restart gosuv server"
    ${GOSUV} restart-server || exit 1
    infoLog "restart gosuv server ok"
}

function status(){
    infoLog "get gosuv server status"
    ${GOSUV} status-server || exit 1
    ${GOSUV} status || exit 1
}

infoLog "current dir: ${CURR}"
checkScript
checkGosuvPID
case "$1" in
start)
    stop
    start
    ;;
stop)
    stop
    ;;
restart)
    restart
    ;;
status)
    status
    ;;
*)
    echo "Usage: $0 {start|stop|restart|reload|status}"
    exit 1
    ;;
esac
