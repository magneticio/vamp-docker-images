#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`

flag_help=0
flag_docker=0
flag_marathon=0
vamp_version=0.8.0

for key in "$@"
do
case ${key} in
    -h|--help)
    flag_help=1
    ;;
    docker)
    flag_docker=1
    ;;
    marathon)
    flag_marathon=1
    ;;
    -v=*|--version=*)
    vamp_version="${key#*=}"
    shift
    ;;
    *)
    ;;
esac
done

export VAMP_VERSION=${vamp_version}

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝
                       version ${VAMP_VERSION}
                       by magnetic.io
${reset}"

error=0

if [[ ${flag_help} -eq 0 && ${flag_docker} -eq 0 && ${flag_marathon} -eq 0 ]]; then
    error=1
    echo "${red}No task ${yellow}docker${red} or ${yellow}marathon${red} specified.${reset}"
    echo
fi
if [[ ${flag_docker} -eq 1 && ${flag_marathon} -eq 1 ]]; then
    error=1
    echo "${red}Not allowed both ${yellow}docker${red} and ${yellow}marathon${red} to be specified.${reset}"
    echo
fi

if [ ${flag_help} -eq 1 ] || [[ ${error} -ne 0 ]]; then
    echo "${green}Usage: $0 docker|marathon [options] ${reset}"
    echo "${yellow}  docker            ${green}Running Vamp using Docker driver.${reset}"
    echo "${yellow}  marathon          ${green}Running Vamp using Marathon driver..${reset}"
    echo "${yellow}  -h  |--help       ${green}Help.${reset}"
    echo "${yellow}  -v=*|--version=*  ${green}Specifying Vamp version, e.g. -v=0.8.0${reset}"
    echo
    if [[ ${error} -ne 0 ]]; then
        exit ${error}
    fi
fi

target_dir=${dir}/"target"
compose_file=${target_dir}/compose.yml

if [[ ${flag_docker} -eq 1 ]]; then
    echo "${green}Running: docker${reset}"

    rm -f ${compose_file} 2> /dev/null && mkdir -p ${target_dir} 2> /dev/null && touch ${compose_file}

    cat ${dir}/compose/zookeeper.yml >> ${compose_file}
    cat ${dir}/compose/elk.yml >> ${compose_file}
    cat ${dir}/compose/vamp-gateway-agent.yml >> ${compose_file}

    docker-compose -f ${compose_file} -p vamp up
fi

if [[ ${flag_marathon} -eq 1 ]]; then
    echo "${green}Running: marathon${reset}"
    rm -f ${compose_file} 2> /dev/null && mkdir -p ${target_dir} 2> /dev/null && touch ${compose_file}

    cat ${dir}/compose/zookeeper.yml >> ${compose_file}
    cat ${dir}/compose/marathon.yml >> ${compose_file}
    cat ${dir}/compose/elk.yml >> ${compose_file}
    cat ${dir}/compose/vamp-gateway-agent.yml >> ${compose_file}

    docker-compose -f ${compose_file} -p vamp up
fi
