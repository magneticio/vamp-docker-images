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

flag_marathon=0

for key in "$@"
do
case ${key} in
    marathon)
    flag_marathon=1
    ;;
    vamp-marathon.yml)
    flag_marathon=1
    ;;
    *)
    ;;
esac
done


if [ ${flag_marathon} -eq 1 ]; then
    echo "${green}running vamp-marathon${reset}"
    docker-compose -f vamp-marathon.yml -p vamp up
fi

if [ ${flag_marathon} -eq 0 ]; then
    echo "${red}usage: ./run.sh marathon${reset}"
fi