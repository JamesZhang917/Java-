#!/bin/bash

# 工作目录
PROJECT_ROOT=$(
  cd $(dirname $0)
  pwd
)
# 项目名称，默认工程文件夹名
PROJECT_NAME="${PROJECT_ROOT##*/}"
# build目标目录
RELEASE_DIR=${PROJECT_ROOT}/output
# gradle build脚本
BUILD_JAR_DIR=${PROJECT_ROOT}/build/libs
# 编译后的jar包名
JAR_NAME=""
#编译的profile类型
GRADLE_PROFILE_TYPE="development"
#gradle编译文件
GRADLE_LIB="${PROJECT_ROOT}/gradlew"
#编译依赖时是否需要强制刷新
REFRESH_DEPENDENCIE=0

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

function precheck() {
    if [[ ! -f "${PROJECT_ROOT}/gradlew" ]]; then
        errLog "cannot find ${PROJECT_ROOT}/gradlew"
    fi
    processLog "precheck done"
}

function build() {
    processLog "building"
    if [[ ${REFRESH_DEPENDENCIE} -eq 1 ]]; then
        ${GRADLE_LIB} clean output -Pprofile=${GRADLE_PROFILE_TYPE} -q --refresh-dependencies
    else
        ${GRADLE_LIB} clean output -Pprofile=${GRADLE_PROFILE_TYPE} -q
    fi
    local result=$?
    if [[ $result -gt 0 ]]; then
      errLog "gradle run failed"
    fi
    #获取编译产出的包名
    JAR_NAME=$(ls ${BUILD_JAR_DIR} | awk '{print $NF}' | grep ".*ar")
    if [[ x"" == x"${JAR_NAME}" ]]; then
        errLog "gradlew build done, but find no jar"
    fi
    processLog "build jar(${JAR_NAME}) done"
}

function release() {
    processLog "release to ${RELEASE_DIR}/ done"
}

function showhelp() {
    echo "usage: build.sh [option...]"
    echo "example:
            1. sh bulid.sh
            2. sh build.sh -p development
            3. sh build.sh -p production"
    echo "-p      add gradlew args, -Pprofile=value, values are 'development'(default), 'production', you need have config/${env} dir."
}

function getparam() {
    while getopts ":p:h" OPTION; do
        case ${OPTION} in
        p)
            if [ ! -d ${PROJECT_ROOT}/config/${OPTARG} ]; then
                showhelp
                exit 2
            fi
            GRADLE_PROFILE_TYPE=${OPTARG}
            ;;
        ?)
            showhelp
            exit 2
            ;;
        esac
    done
    if [[ x"" = x"${GRADLE_PROFILE_TYPE}" ]]; then
        GRADLE_PROFILE_TYPE="development"
    fi
    infoLog "build env: ${GRADLE_PROFILE_TYPE}"
}

getparam $*

cd ${PROJECT_ROOT}
processLog "start build ${PROJECT_NAME}"
precheck
build
release
processLog "${PROJECT_NAME} done"
exit 0
