#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${dir}/common.sh"${@}"

echo "${green}Building ${yellow}'clique-zookeeper-marathon'${reset} Docker image${reset}"
build-clique

echo "${green}Done.${reset}"
