#!/bin/bash
SHELL_ROOT=$(cd `dirname $0`; pwd)
PROJECT_ROOT=${SHELL_ROOT}/../

if [ ! -d ${PROJECT_ROOT} ];then
  echo dir ${PROJECT_ROOT} not exist
  exit 1
fi
echo ${PROJECT_ROOT}
cd ${PROJECT_ROOT}

# 合并master分支代码
echo "1. 合并master分支代码"
git pull
git pull origin master

echo ""
# 获取要发布的分支版本号
echo "2. 获取版本号"
VERSION=`grep VERSION gradle.properties | awk -F'=' '{print $2}'`
echo $VERSION
echo ""
echo "{\"version\": \"${VERSION}\"}" > ${PROJECT_ROOT}/package.json

# 自动更新changelog
echo "3. 生成change log"
conventional-changelog -p angular -i CHANGELOG.md -s
git add ${PROJECT_ROOT}/package.json ${PROJECT_ROOT}/CHANGELOG.md
git commit -m "chore(release): v${VERSION}"
echo ""

# 增加版本tag
echo "4. 生成tag v$VERSION"
git tag v${VERSION}
echo ""

echo "1.请检查本地代码、提交日志等信息是否有遗漏"
echo "2.通过git rebase相关操作合并提交记录，按照功能划分"
echo "3.通过git push --follow-tags origin v$VERSION 提交tag"
echo "4.通过git push origin $VERSION 提交代码"
