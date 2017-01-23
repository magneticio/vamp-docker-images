#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`

# Exit if we don't have npm available
hash npm || exit 1

target=$1
mkdir -p ${target} && cd ${target}

echo "${green}Cloning Vamp UI to ${target}...${reset}"

[[ -n "$VAMP_BUILD_UI_BRANCH" ]] \
  && git clone --depth=200 --branch="$VAMP_BUILD_UI_BRANCH" https://github.com/magneticio/vamp-ui.git \
  || git clone --depth=200 https://github.com/magneticio/vamp-ui.git

cd ${target}/vamp-ui
echo "${green}Building Vamp UI...${reset}"

npm install "gulpjs/gulp#4.0" bower \
  && npm install \
  && ./node_modules/.bin/bower --allow-root install \
  && ./environment.sh \
  && ./node_modules/.bin/gulp build \
  || exit 1

mv dist ui && tar -cvjSf ui.tar.bz2 ui
cd ${target}

echo "${green}Cloning Vamp to ${target}...${reset}"

[[ -n "$VAMP_BUILD_BRANCH" ]] \
  && git clone --depth=200 --branch="$VAMP_BUILD_BRANCH" https://github.com/magneticio/vamp.git \
  || git clone --depth=200 https://github.com/magneticio/vamp.git

cd ${target}/vamp
echo "${green}Building Vamp...${reset}"
make pack

echo "${green}Copying files...${reset}"
cp $(find "${target}/vamp/bootstrap/target" -name 'vamp-*.tar.gz' | sort | tail -1) ${target}/.
cp -f ${target}/vamp-ui/ui.tar.bz2 ${target}/ui.tar.bz2

rm -Rf ${target}/vamp && rm -Rf ${target}/vamp-ui

mkdir -p ${target}/artifacts/breeds ${target}/artifacts/blueprints ${target}/artifacts/workflows

curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/breeds/allocation.js -o ${target}/artifacts/breeds/allocation.js
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/breeds/health.js -o ${target}/artifacts/breeds/health.js
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/breeds/kibana.js -o ${target}/artifacts/breeds/kibana.js
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/breeds/metrics.js -o ${target}/artifacts/breeds/metrics.js

curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/blueprints/sava:1.0.yml -o ${target}/artifacts/blueprints/sava:1.0.yml
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/blueprints/sava:1.1.yml -o ${target}/artifacts/blueprints/sava:1.1.yml

curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/workflows/allocation.yml -o ${target}/artifacts/workflows/allocation.yml
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/workflows/health.yml -o ${target}/artifacts/workflows/health.yml
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/workflows/kibana.yml -o ${target}/artifacts/workflows/kibana.yml
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/workflows/metrics.yml -o ${target}/artifacts/workflows/metrics.yml

cp -f ${dir}/Dockerfile ${target}/Dockerfile
cp -fR ${dir}/logback.xml ${dir}/application.conf ${target}/
cp -f ${dir}/vamp.sh ${target}/
cp -fR ${dir}/supervisord.conf ${target}/
