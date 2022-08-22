#!/bin/bash
#sudo npm install -g commitizen cz-conventional-changelog-cli
#sudo npm install -g cz-conventional-changelog
#echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc

SHELL_ROOT=$(cd `dirname $0`; pwd)
PROJECT_ROOT=${SHELL_ROOT}/..
cd ${PROJECT_ROOT}

# 生成changelog.md
conventional-changelog -p angular -i CHANGELOG.md -s
