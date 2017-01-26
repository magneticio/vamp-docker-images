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
rm -Rf ${workspace} && mkdir ${workspace}

pack() {
  project=$1
  echo "${green}project: ${yellow}${project}${reset}"
  cd ${workspace}
  git clone --depth=200 https://github.com/magneticio/${project}.git
  cd ${workspace}/${project}
  make pack
}

pack vamp
pack vamp-ui
pack vamp-dcos
pack vamp-etcd
pack vamp-redis
pack vamp-consul
pack vamp-docker
pack vamp-lifter
pack vamp-rancher
pack vamp-haproxy
pack vamp-zookeeper
pack vamp-artifacts
pack vamp-kubernetes
pack vamp-elasticsearch
