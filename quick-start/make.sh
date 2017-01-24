#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`

target=$1
mkdir -p ${target} && cd ${target}

: "${CLEAN_BUILD:=true}"

if [ "$CLEAN_BUILD" = "true" ]; then
  source ${dir}/pack.sh
fi

function pull() {
  project=$1
  mkdir ${target}/${project}
  docker run \
    --entrypoint=/bin/pull \
    -v ${target}/${project}:/usr/local/dst \
    -v packer:/usr/local/stash \
    magneticio/packer ${project}
}

pull vamp
pull vamp-ui
pull vamp-artifacts
rm ${target}/vamp-artifacts/breeds/vga.js
rm ${target}/vamp-artifacts/workflows/vga.yml

cp -f ${dir}/Dockerfile ${target}/Dockerfile
cp -fR ${dir}/logback.xml ${dir}/application.conf ${target}/
cp -f ${dir}/vamp.sh ${target}/
cp -fR ${dir}/supervisord.conf ${target}/
