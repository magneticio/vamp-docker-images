#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${dir}/common.sh

if [ "${CLEAN_BUILD:-true}" = "true" ]; then
  echo "${green}Building ${yellow}'vamp-gateway-agent' and 'vamp-workflow-agent'${reset} Docker images${reset}"
  build-agents
fi

echo "${green}Building ${yellow}'vamp'${reset} Docker image${reset}"
build-vamp

echo "${green}Building ${yellow}'vamp-compose'${reset} Docker image${reset}"
cd ${dir} && ../build.sh --build --image=vamp-compose

echo "${green}Done.${reset}"
