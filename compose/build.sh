#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`

test -f ${dir}/../local.sh && source ${dir}/../local.sh

cd ${dir}/

echo "${green}Building ${yellow}'magneticio/java:openjdk-8-jre-alpine'${reset} Docker image${reset}"
../build.sh --make --image=alpine-jdk

echo "${green}Building ${yellow}'vamp'${reset} Docker image${reset}"
bash -x ../build.sh --build --image=vamp

echo "${green}Building ${yellow}'vamp-compose'${reset} Docker image${reset}"
../build.sh --build --image=vamp-compose

echo "${green}Done.${reset}"
