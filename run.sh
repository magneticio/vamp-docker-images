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

target_dir=${dir}/"target"
compose_file=${target_dir}/compose.yml

case "$1" in
    docker)
    rm -f ${compose_file} 2> /dev/null && mkdir -p ${target_dir} 2> /dev/null && touch ${compose_file}

    cat ${dir}/compose/zookeeper.yml >> ${compose_file}
    cat ${dir}/compose/elk.yml >> ${compose_file}
    cat ${dir}/compose/vamp-gateway-agent.yml >> ${compose_file}

    docker-compose -f ${compose_file} -p vamp up
    ;;
    marathon)
    rm -f ${compose_file} 2> /dev/null && mkdir -p ${target_dir} 2> /dev/null && touch ${compose_file}

    cat ${dir}/compose/zookeeper.yml >> ${compose_file}
    cat ${dir}/compose/marathon.yml >> ${compose_file}
    cat ${dir}/compose/elk.yml >> ${compose_file}
    cat ${dir}/compose/vamp-gateway-agent.yml >> ${compose_file}

    docker-compose -f ${compose_file} -p vamp up
    ;;
    *)
    echo "${green}Usage: run.sh docker|marathon

    docker     Running Vamp using Docker driver.
    marathon   Running Vamp using Marathon driver.
${reset}"
    ;;
esac
