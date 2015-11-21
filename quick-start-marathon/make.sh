#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`

target=$1

#vamp_revision=2f48fb8

echo "${green}Cloning Vamp to ${target}...${reset}"
mkdir -p ${target} && cd ${target}
git clone -b develop --recursive --depth=1 git@github.com:magneticio/vamp.git
cd ${target}/vamp
#git checkout ${vamp_revision} .

echo "${green}Building Vamp...${reset}"
./build-ui.sh && sbt test assembly

echo "${green}Copying files...${reset}"
cp $(find "${target}/vamp/bootstrap/target/scala-2.11" -name 'vamp-assembly-*.jar' | sort | tail -1) ${target}/vamp.jar
rm -Rf ${target}/vamp
cp -f ${dir}/Dockerfile ${target}/Dockerfile
cp -fR ${dir}/conf ${target}/
cp -f ${dir}/start.sh ${target}/
cp -fR ${dir}/supervisord.conf ${target}/
