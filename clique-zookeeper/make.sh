#!/usr/bin/env bash

set -e

function get-home-dir() {
  (cd "${HOME}" && pwd)
}

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`
yellow=`tput setaf 3`

test -f "${dir}"/../local.sh && source "${dir}"/../local.sh
build_server=${BUILD_SERVER:-"magneticio/buildserver"}
dir_m2="$(get-home-dir)"/.m2/repository

test "${DEPS_OK:=}" = "true" || docker pull $build_server

target="$1"
mkdir -p "${target}" && cd "${target}"

echo "${green}building: ${yellow}zk-web${reset}"

if [[ -d "${target}"/zk-web ]] ; then

  docker run \
    --interactive \
    --rm \
    --volume "${target}":/srv/src \
    --workdir=/srv/src \
    $build_server \
      rm -rf /srv/src/zk-web
fi

git clone --depth=1 https://github.com/qiuxiafei/zk-web.git
cd "${target}"/zk-web

docker run \
  --interactive \
  --rm \
  --volume "${target}"/zk-web:/srv/src \
  --volume "${dir_m2}":/home/vamp/.m2/repository \
  --workdir=/srv/src \
  --env BUILD_UID=$(id -u) \
  --env BUILD_GID=$(id -g) \
  $build_server \
    lein uberjar

cp "${target}"/zk-web/target/zk-web-*-standalone.jar "${target}"/zk-web.jar

echo "${green}copying files...${reset}"
cp -f "${dir}"/zk.sh "${target}"/zk.sh
cp -f "${dir}"/zk-web-conf.clj "${target}"/zk-web-conf.clj
cp -f "${dir}"/Dockerfile "${target}"/Dockerfile
cp -f "${dir}"/log4j.properties "${target}"/log4j.properties
cp -f "${dir}"/supervisord.conf "${target}"/supervisord.conf
