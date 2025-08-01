#!/bin/bash

set -e

echo Launcher sha256sum
sha256sum build/libs/Jirenyte.jar

cmake -S liblauncher -B liblauncher/build64 -A x64
cmake --build liblauncher/build64 --config Release

pushd native
cmake -B build-x64 -A x64
cmake --build build-x64 --config Release
popd

source .jdk-versions.sh

rm -rf build/win-x64
mkdir -p build/win-x64

if ! [ -f win64_jre.zip ] ; then
    curl -Lo win64_jre.zip $WIN64_LINK
fi

echo "$WIN64_CHKSUM win64_jre.zip" | sha256sum -c

cp native/build-x64/src/Release/Jirenyte.exe build/win-x64/
cp build/libs/Jirenyte.jar build/win-x64/
cp packr/win-x64-config.json build/win-x64/config.json
cp liblauncher/build64/Release/launcher_amd64.dll build/win-x64/

unzip win64_jre.zip
mv jdk-$WIN64_VERSION-jre build/win-x64/jre

echo Jirenyte.exe 64bit sha256sum
sha256sum build/win-x64/Jirenyte.exe

dumpbin //HEADERS build/win-x64/Jirenyte.exe

# We use the filtered iss file
iscc build/filtered-resources/runelite.iss