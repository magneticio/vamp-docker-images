#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`
yellow=$(tput setaf 3)

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
  docker run \
    --entrypoint=/bin/pull \
    -v ${target}/${project}:/usr/local/dst \
    -v packer:/usr/local/stash \
    magneticio/packer ${project}
}

function join() {
  project=$1
  pull ${project}
  cp -R ${target}/${project}/* ${target}/vamp/ && rm -Rf ${target}/${project}
}

pull vamp
pull vamp-ui
join vamp-dcos
join vamp-etcd
join vamp-consul
join vamp-lifter
join vamp-rancher
join vamp-haproxy
join vamp-zookeeper
pull vamp-artifacts
join vamp-kubernetes
join vamp-elasticsearch

cp -f ${dir}/Dockerfile ${dir}/vamp.sh ${dir}/logback.xml ${target}/
