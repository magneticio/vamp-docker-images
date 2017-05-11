#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`
yellow=$(tput setaf 3)

[[ -n $1 ]] && target=$1 || { >&2 echo "missing input, exiting"; exit 1; }
mkdir -p ${target} && cd ${target}

if [[ $( git describe --tags --abbrev=0 ) = $( git describe --tags ) ]] ; then
  vamp_version="$( git describe --tags )"
else
  vamp_version="katana"
fi

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
    --volume "${target}/${project}":/usr/local/dst \
    --volume packer:/usr/local/stash \
    magneticio/buildserver \
      pull "$project" "$vamp_version"
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
join vamp-mysql
join vamp-postgresql
join vamp-sqlserver
pull vamp-artifacts
join vamp-kubernetes
join vamp-elasticsearch

cp -Rf ${dir}/files ${target}/
cp -f ${dir}/Dockerfile ${target}/
