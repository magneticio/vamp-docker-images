#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`

target=$1

echo "${green}cloning mesosphere/marathon to ${target}...${reset}"
git clone https://github.com/mesosphere/marathon.git ${target}
cd ${target} && git checkout tags/v0.11.1

echo "${green}copying files...${reset}"
cp -f ${dir}/Dockerfile ${target}/Dockerfile
cp -f ${dir}/start.sh ${target}/start.sh
