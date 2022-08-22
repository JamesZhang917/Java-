#!/bin/bash

CURR=$(
  cd $(dirname $0)
  pwd
)

PROGRAMS_FILE_NAME="programs.yml"
CONFIG_FILE_NAME="config.yml"

# 服务名
SERV_NAME=""
# jar包名称
JAR_NAME=""
# jar包所在工作目录
WORK_DIR=""
APP_FILE="${WORK_DIR}/${JAR_NAME}"
RUN_LOG_DIR="${WORK_DIR}/log/run"
RUN_LOG_FILE="${WORK_DIR}/run.log"

JAVA="java"
# wiki http://wiki.sftcwl.com/pages/viewpage.action?pageId=34649890
JAVA_OPTS="-server -Xmx1344M -Xms1344M -Xmn448M -Xss256k"
JAVA_OPTS="${JAVA_OPTS} -XX:MaxMetaspaceSize=256M -XX:MetaspaceSize=256M"
# gc相关
JAVA_OPTS="${JAVA_OPTS} -verbose:gc"
JAVA_OPTS="${JAVA_OPTS} -Xloggc:${RUN_LOG_DIR}/gc%t.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=50M"
JAVA_OPTS="${JAVA_OPTS} -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${RUN_LOG_DIR}/"
#
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintCommandLineFlags"
# 关闭fastthrow
JAVA_OPTS="${JAVA_OPTS} -XX:-OmitStackTraceInFastThrow"
# 日志
#JAVA_OPTS="${JAVA_OPTS} --logging.config=${CURR}/config/logback-spring.xml"

function errLog() {
  echo " [ERR] $1"
  exit 1
}

function infoLog() {
  echo " [INFO] $1"
}

function processLog() {
  echo " -> $1"
}

function preCheck() {
    if [[ -z "${SERV_NAME}" ]]; then
        errLog "you must set SERV_NAME in this script"
    fi
    if [[ -z "${JAR_NAME}" ]]; then
        errLog "you must set JAR_NAME in this script"
    fi
    if [[ -z "${WORK_DIR}" ]]; then
        errLog "you must set WORK_DIR in this script"
    fi
}

function genProgramsYml() {
    # 打印启动执行命令
    infoLog "gen programs.yml begin"

    processLog "${JAVA} ${JAVA_OPTS} -jar ${APP_FILE}"
    processLog ""
    rm ${PROGRAMS_FILE_NAME}
    # 更新programs.yml中的启动命令
    echo "- name: ${SERV_NAME}
  command: ${JAVA} ${JAVA_OPTS} -jar ${APP_FILE}
  directory: ${WORK_DIR}
  environ: []
  # 启动gosuv的时候自动启动
  start_auto: true
  start_retries: 3
  # 停止超时时间30s
  stop_timeout: 30
  # 只有root用户可以指定用其他用户启动进程, 一般留空即可
  user:" > ${PROGRAMS_FILE_NAME}

    infoLog "gen programs.yml end"
}

function genConfigYml() {
    # 打印启动执行命令
    infoLog "gen config.yml begin"

    rm ${CONFIG_FILE_NAME}
    echo "include: \"\"
server:
  httpserver:
    enabled: false
    addr: :8000
  unixserver:
    enabled: true
    sockfile: .gosuv.sock
  auth:
    enabled: true
    username: admin
    password: admin
    ipfile: \"\"
  pidfile: .gosuv.pid
  log:
    logpath: gosuvlogs
    level: info
    filemax: 10000
    backups: 10
  minfds: 1024
  minprocs: 1024
client:
  server_url: unix://.gosuv.sock
  username: admin
  password: admin" > ${CONFIG_FILE_NAME}
    infoLog "gen config.yml end"
}

preCheck
genProgramsYml
genConfigYml
