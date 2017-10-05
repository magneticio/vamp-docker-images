#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝
                       by magnetic.io
${reset}"

set -m
cd ${dir}

DOCKER_COMPOSE_FILE=$1

if [ -z ${DOCKER_COMPOSE_FILE} ]; then
  DOCKER_COMPOSE_FILE=docker-compose.yml
  echo "${green}Docker compose file not specified, using: ${yellow}${DOCKER_COMPOSE_FILE}${reset}"
else
  echo "${green}Docker compose file: ${yellow}${DOCKER_COMPOSE_FILE}${reset}"
fi

echo "${green}Running Docker compose${reset}"
docker-compose -f ${DOCKER_COMPOSE_FILE} -p vamp up -d --force-recreate

MARATHON=http://localhost:8090/v2/apps
while true; do
  status=$(curl -s -w '%{http_code}' ${MARATHON} -o /dev/null)
  if [ ${status} -eq 200 ]; then
    echo "${green}Marathon is up, starting Vamp${reset}"
    break
  else
    echo "${yellow}Waiting for Marathon...${reset}"
  fi
  sleep 5
  test $? -gt 128 && exit
done

echo "${green}Deploying Vamp${reset}"
curl -X POST ${MARATHON} -d @vamp.json -H "Content-type: application/json"
echo

if [ ${DOCKER_COMPOSE_FILE} == 'docker-compose.yml' ]; then
  echo "${green}Deploying Vamp Gateway Agent${reset}"
  curl -X POST ${MARATHON} -d @vga.json -H "Content-type: application/json"
  echo
fi

echo "${green}Running.${reset}"
