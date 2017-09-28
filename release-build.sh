#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

if [[ -z $1 ]] ; then
  >&2 echo "Missing argument!"
  echo "Usage:"
  echo "  release-build.sh <version>"
  echo ""
  echo "Example:"
  echo "  release-build.sh 0.9.3"
  exit 1
else
  TAG="$1"
  if [[ $( git tag | tail -n1 ) != "$TAG" ]] ; then
    >&2 echo "${red}Error: Provided tag doesn't match repository tag!${reset}"
    >&2 echo "Have you exectued 'release-tag.sh'???"
    >&2 echo "Exiting..."
    exit 1
  fi
fi

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗     ██████╗ ██╗   ██╗██╗██╗     ██████╗ ███████╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗    ██╔══██╗██║   ██║██║██║     ██╔══██╗██╔════╝██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝    ██████╔╝██║   ██║██║██║     ██║  ██║█████╗  ██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝     ██╔══██╗██║   ██║██║██║     ██║  ██║██╔══╝  ██╔══██╗
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║         ██████╔╝╚██████╔╝██║███████╗██████╔╝███████╗██║  ██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝         ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝
                                                                     by magnetic.io
${reset}"

workspace=${root}/target
mkdir -p ${workspace}

build_external() {
  project=$1
  echo "${green}project: ${yellow}${project}${reset}"

  if [[ ! -d ${workspace}/${project} ]] ; then
    >&2 echo "${red}Project doesn't exits: ${project}${project}"
    >&2 echo "Have you exectued 'release-tag.sh'???"
    >&2 echo "Exiting..."
    exit 1
  fi

  cd ${workspace}/${project}

  if [[ $( git tag | tail -n1 ) != "$TAG" ]] ; then
    >&2 echo "${red}Error: Provided tag doesn't match repository tag!${reset}"
    >&2 echo "Have you exectued 'release-tag.sh'???"
    >&2 echo "Exiting..."
    exit 1
  fi

  make
}

build_ee() {
  project="vamp-ee"
  echo "${green}project: ${yellow}${project}${reset}"

  if [[ ! -d ${workspace}/${project} ]] ; then
    >&2 echo "${red}Project doesn't exits: ${project}${project}"
    >&2 echo "Have you exectued 'release-tag.sh'???"
    >&2 echo "Exiting..."
    exit 1
  fi

  cd ${workspace}/${project}

  if [[ $( git tag | tail -n1 ) != "$TAG" ]] ; then
    >&2 echo "${red}Error: Provided tag doesn't match repository tag!${reset}"
    >&2 echo "Have you exectued 'release-tag.sh'???"
    >&2 echo "Exiting..."
    exit 1
  fi

  ./docker/dcos/make.sh
  ./docker/local/make.sh
  cd -
}

# Disable the clean builds of various sub-build scripts
export CLEAN_BUILD=false

source ${root}/pack.sh

${root}/build.sh --build --image=vamp
${root}/build.sh --build --image=vamp-custom
${root}/build.sh --build --image=vamp-dcos
${root}/build.sh --build --image=vamp-kubernetes

build_external vamp-gateway-agent
build_external vamp-workflow-agent
build_external vamp-runner

docker tag "magneticio/vamp-runner:katana" "magneticio/vamp-runner:$TAG"


# Build the quick-start images
${root}/build.sh --build --image=clique-base
${root}/build.sh --build --image=clique-zookeeper
${root}/build.sh --build --image=clique-zookeeper-marathon
${root}/build.sh --build --image=quick-start

docker tag "magneticio/vamp-quick-start:$TAG" "magneticio/vamp-docker:$TAG"

build_ee
docker tag "magneticio/vamp-quick-start-ee:katana" "magneticio/vamp-ee:katana"
docker tag "magneticio/vamp-quick-start-ee:katana" "magneticio/vamp-ee:$TAG"
docker tag "magneticio/vamp-ee:katana-dcos" "magneticio/vamp-ee:$TAG-dcos"
