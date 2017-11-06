#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`

echo "${green}Building ${yellow}'magneticio/java:openjdk-8-jre-alpine'${reset} Docker image${reset}"
cd ${dir}/../alpine-jdk && make build

echo "${green}Building ${yellow}'vamp'${reset} Docker image${reset}"
cd ${dir} && ../build.sh -b -c -i=vamp

echo "${green}Building ${yellow}'vamp-compose'${reset} Docker image${reset}"
../build.sh -b -c -i=vamp-compose

echo "${green}Done.${reset}"
