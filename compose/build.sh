#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`

cd ${dir}

LOGSTASH=2.3.3
KIBANA=4.5.1

function docker_build {
    echo "${green}building docker image: $1 ${reset}"
    docker build -t $1 $2
}

function docker_rmi {
    echo "${green}removing docker image: $1 ${reset}"
    docker rmi -f $1 2> /dev/null
}

function parse_command_line() {
    flag_help=0
    flag_clean=0
    flag_build=0

    for key in "$@"
    do
    case ${key} in
        -h|--help)
        flag_help=1
        ;;
        -c|--clean)
        flag_clean=1
        ;;
        -b|--build)
        flag_make=1
        flag_build=1
        ;;
        *)
        ;;
    esac
    done
}

function print_help() {
    echo "${green}Usage of $0:${reset}"
    echo "${yellow}  -h  |--help       ${green}Help.${reset}"
    echo "${yellow}  -c  |--clean      ${green}Remove all available images.${reset}"
    echo "${yellow}  -b  |--build      ${green}Build all available images.${reset}"
}

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝
                       by magnetic.io
${reset}"

parse_command_line $@

if [ ${flag_help} -eq 1 ] || [[ $# -eq 0 ]]; then
    print_help
fi

if [ ${flag_clean} -eq 1 ]; then
    docker_rmi magneticio/logstash:${LOGSTASH}
    docker_rmi magneticio/kibana:${KIBANA}
fi

if [ ${flag_build} -eq 1 ]; then
    docker_build magneticio/logstash:${LOGSTASH} ${dir}/logstash
    docker_build magneticio/kibana:${KIBANA} ${dir}/kibana
fi
