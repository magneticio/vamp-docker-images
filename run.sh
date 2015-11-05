#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`

export VAMP_VERSION=0.8.0
echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝
                       gateway agent
                       version ${VAMP_VERSION}
                       by magnetic.io
${reset}"

case "$1" in
    docker)
    docker-compose -f ${dir}/compose/vamp-docker-driver.yml -p vamp up
    ;;
    marathon)
    docker-compose -f ${dir}/compose/vamp-marathon-driver.yml -p vamp up
    ;;
    *)
    echo "${green}Usage: run.sh docker|marathon

    docker     Running Vamp using Docker driver.
    marathon   Running Vamp using Marathon driver.
${reset}"
    ;;
esac
