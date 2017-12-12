#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`

test -f ${dir}/../local.sh && source ${dir}/../local.sh

cd ${dir}/

echo "${green}Building ${yellow}'clique-base'${reset} Docker image${reset}"
../build.sh --build --image=clique-base

echo "${green}Building ${yellow}'clique-zookeeper'${reset} Docker image${reset}"
../build.sh --build --image=clique-zookeeper

echo "${green}Building ${yellow}'clique-zookeeper-marathon'${reset} Docker image${reset}"
../build.sh --build --image=clique-zookeeper-marathon

echo "${green}Done.${reset}"
