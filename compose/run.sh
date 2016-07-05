#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`

cd ${dir}

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝
                       by magnetic.io
${reset}"

docker-compose -f ${dir}/vamp.yml -p vamp up