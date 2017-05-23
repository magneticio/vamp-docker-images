#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗     ██████╗  █████╗  ██████╗██╗  ██╗███████╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗    ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝    ██████╔╝███████║██║     █████╔╝ █████╗  ██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝     ██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║         ██║     ██║  ██║╚██████╗██║  ██╗███████╗██║  ██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝         ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                                                          by magnetic.io
${reset}"

workspace=${root}/target
mkdir -p ${workspace}

pack() {
  project=$1
  url="https://github.com/magneticio/${project}.git"
  echo "${green}project: ${yellow}${project}${reset}"
  cd ${workspace}

  if [[ -d ${workspace}/${project} ]] ; then
    echo "${green}updating existing repository${reset}"

    cd ${workspace}/${project}

    git reset --hard
    git checkout master
    git pull

  else
    git clone --depth=200 "$url"
    cd ${workspace}/${project}

  fi

  make pack
}

pack vamp
pack vamp-haproxy
pack vamp-elasticsearch
pack vamp-mysql
pack vamp-postgresql
pack vamp-sqlserver
pack vamp-zookeeper
pack vamp-etcd
pack vamp-redis
pack vamp-consul
pack vamp-dcos
pack vamp-docker
pack vamp-kubernetes
pack vamp-rancher
pack vamp-config
pack vamp-lifter
pack vamp-ui
pack vamp-artifacts
