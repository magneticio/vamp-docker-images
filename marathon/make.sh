#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`

target=$1
tmp=${target}/tmp
marathon_version=v0.13.0-RC3

echo "${green}cloning mesosphere/marathon ${marathon_version} to ${target}...${reset}"
git clone https://github.com/mesosphere/marathon.git ${tmp}
cd ${tmp} && git checkout tags/${marathon_version}

echo "${green}building...${reset}"
sbt -Dsbt.log.format=false assembly
cp $(find "${tmp}" -name 'marathon-assembly-*.jar' | sort | tail -1) ${target}/marathon.jar
rm -Rf ${tmp} 2> /dev/null

echo "${green}copying files...${reset}"
cp -f ${dir}/Dockerfile ${target}/Dockerfile
cp -f ${dir}/start.sh ${target}/start.sh
