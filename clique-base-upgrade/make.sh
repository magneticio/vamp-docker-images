#!/usr/bin/env bash

set -e

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`
yellow=`tput setaf 3`

target=$1

echo "${green}copying files...${reset}"
mkdir -p ${target}
cd ${dir}
cp -f ${dir}/Dockerfile ${target}/Dockerfile
cp -Rf ${dir}/elasticsearch ${target}/
cp -Rf ${dir}/kibana ${target}/
cp -f ${dir}/supervisord.conf ${target}/supervisord.conf
