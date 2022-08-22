#!/bin/sh

PROJECT_ROOT=$(
  cd $(dirname $0)
  pwd
)

latestVersion=`curl -s -H "PRIVATE-TOKEN:PcFyt9mD54yghRwYRHvT" "https://gitlab.sftcwl.com/api/v4/projects/487/repository/files/release%2Ftools%2Flatest/raw?ref=upgrade_tools"`

echo "最新版本："$latestVersion

if [ -f ~/.gradle/sftech-build-tools/build-tools-$latestVersion.jar ];then
    echo "build-tools-$latestVersion.jar已存在，无需更新"
else
    echo "下载build-tools-$latestVersion.jar"
    mkdir -p ~/.gradle/sftech-build-tools/
    curl -s -o ~/.gradle/sftech-build-tools/build-tools-$latestVersion.jar -H "PRIVATE-TOKEN:PcFyt9mD54yghRwYRHvT" "https://gitlab.sftcwl.com/api/v4/projects/487/repository/files/release%2Ftools%2Fbuild-tools-$latestVersion.jar/raw?ref=upgrade_tools"
    echo $?
fi
echo "启动build-tools"
echo ""
java -jar ~/.gradle/sftech-build-tools/build-tools-$latestVersion.jar --upgrade
