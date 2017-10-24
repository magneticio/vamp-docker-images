#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`
yellow=$(tput setaf 3)

build_server="magneticio/buildserver"
test -f ${dir}/local.sh && source ${dir}/local.sh

docker pull $build_server

target=$1
mkdir -p ${target} && cd ${target}

: "${CLEAN_BUILD:=true}"

if [ "$CLEAN_BUILD" = "true" ]; then
  source ${dir}/../pack.sh
  rm -Rf ${target} && mkdir -p ${target} && cd ${target}
fi

function pull() {
  project=$1
  echo "${green}pulling project: ${yellow}${project}${reset}"
  mkdir ${target}/${project}

  docker volume create packer
  docker run \
    --rm \
    --volume "${target}/${project}":/usr/local/dst \
    --volume packer:/usr/local/stash \
    $build_server \
      pull "$project"
}

pull vamp
pull vamp-ui
pull vamp-artifacts

cp -R ${dir}/artifacts/* ${target}/vamp-artifacts
cp -f ${dir}/Dockerfile ${target}/Dockerfile
cp -fR ${dir}/logback.xml ${dir}/application.conf ${target}/
cp -f ${dir}/vamp.sh ${target}/
cp -fR ${dir}/supervisord.conf ${target}/
