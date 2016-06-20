#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`

target=$1
mkdir -p ${target} && cd ${target}

echo "${green}Cloning Vamp UI to ${target}...${reset}"
git clone -b develop --depth=1 git@github.com:magneticio/revamp-ui.git
cd ${target}/revamp-ui
echo "${green}Building Vamp UI...${reset}"
npm install -g gulp && npm install && bower install && gulp build
mv dist ui && tar -cvjSf ui.tar.bz2 ui
cd ${target}

echo "${green}Cloning Vamp to ${target}...${reset}"
git clone -b develop --depth=1 git@github.com:magneticio/vamp.git
cd ${target}/vamp
echo "${green}Building Vamp...${reset}"
sbt test assembly

echo "${green}Copying files...${reset}"

cp $(find "${target}/vamp/bootstrap/target/scala-2.11" -name 'vamp-assembly-*.jar' | sort | tail -1) ${target}/vamp.jar
cp -f ${target}/revamp-ui/ui.tar.bz2 ${target}/ui.tar.bz2
cp -f ${dir}/Dockerfile ${dir}/vamp.sh ${dir}/logback.xml ${target}/
rm -Rf ${target}/vamp ${target}/revamp-ui