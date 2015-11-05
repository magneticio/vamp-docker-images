#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`

cd ${dir}

export VAMP_VERSION=0.8.0
echo "${green}Vamp version: ${VAMP_VERSION}${reset}"

echo "${green}Running Docker compose.${reset}"
docker-compose -f vamp-docker-driver.yml -p vamp up
