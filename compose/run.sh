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

set -eu
cd "${dir}"

DOCKER_COMPOSE_FILE=${1:-docker-compose.yml}

CURL=$(which curl)

COMPOSE_SLEEP_TIME=0
MARATON_SLEEP_TIME=10

test -f "${dir}"/../local.sh && source "${dir}"/../local.sh
test -f "${dir}"/.env && source "${dir}"/.env

echo "${green}Docker compose file: ${yellow}${DOCKER_COMPOSE_FILE}${reset}"

function wait_for() {
  sleep ${COMPOSE_SLEEP_TIME}
  local id=${1:-}
  local url=${2:-}
  local filter=${3:-}
  local body=""
  while true; do
    status=$(${CURL} -s -w '%{http_code}' ${url} -o /dev/null || true)
    test ${status} -eq 200 -o ${status} -eq 201 && test -n "${filter}" && body=$(${CURL} -s ${url} | grep -Eve "${filter}" || true)
    if [ ${status} -eq 200 -o ${status} -eq 201 ] && [ -z "${body}" ]; then
      echo "${green}${id}: OK${reset}"
      break
    else
      echo "${yellow}Waiting for ${id}...${reset}"
    fi
    sleep 1
    test $? -gt 128 && exit
  done
}

function curl() {
  local curl_args="-s --verbose -H Content-Type:application/json -H Accept:application/json,text/plain"
  $(${CURL} ${curl_args} "${@}" > .log 2>&1) || {
    echo "${yellow}Retrying ${CURL} ${curl_args} ${@}${reset}"
    sleep 5
    $(${CURL} ${curl_args} "${@}" > .log 2>&1)
  } || {
    echo "${red}Failed to run ${CURL} ${curl_args} ${@}${reset}"
    cat .log >&2
  }
}

MARATHON=http://localhost:8090/v2/apps

echo "${green}Running Docker compose${reset}"
docker-compose -f ${DOCKER_COMPOSE_FILE} -p vamp up -d --force-recreate

wait_for Marathon ${MARATHON}
if [ "${MARATON_SLEEP_TIME}" -gt 0 ]; then
  echo "${yellow}Waiting ${MARATON_SLEEP_TIME} second(s) before deploying vamp${reset}"
  sleep ${MARATON_SLEEP_TIME}
fi

echo "${green}Deploying Vamp Gateway Agent${reset}"
sed -e "s/katana/${VAMP_VERSION:-katana}/g" vga.json > .data
curl -X POST ${MARATHON} -d @.data

echo "${green}Deploying Vamp${reset}"
sed -e "s/katana/${VAMP_VERSION:-katana}/g" vamp.json > .data
curl -X POST ${MARATHON} -d @.data

echo "${green}Running.
Lifter UI  : http://localhost:8081
Vamp UI    : http://localhost:8080
${reset}"
