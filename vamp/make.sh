#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`

target=$1

echo "${green}Cloning Vamp to ${target}...${reset}"
mkdir -p ${target} && cd ${target}
git clone --recursive --depth=1 git@github.com:magneticio/vamp.git
cd ${target}/vamp

echo "${green}Building Vamp...${reset}"
./build-ui.sh && sbt test assembly

echo "${green}Copying files...${reset}"
cp $(find "${target}/vamp/bootstrap/target/scala-2.11" -name 'vamp-assembly-*.jar' | sort | tail -1) ${target}/vamp.jar
cp $(find "${target}/vamp/cli/target/scala-2.11" -name 'vamp-cli-*.jar' | sort | tail -1) ${target}/vamp-cli.jar

rm -Rf ${target}/vamp
cp -f ${dir}/Dockerfile ${target}/Dockerfile
cp -fR ${dir}/conf ${target}/
cp -f ${dir}/vamp-cli.sh ${target}/vamp-cli.sh
