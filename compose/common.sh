#!/usr/bin/env bash

set -o errexit

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

reset=`tput sgr0`
red=$(tput setaf 1)
green=`tput setaf 2`
yellow=$(tput setaf 3)

test -f ${root}/local.sh && source ${root}/local.sh
build_server=${BUILD_SERVER:-"magneticio/buildserver"}
packer=${PACKER:-packer}
vamp_git_root=${VAMP_GIT_ROOT:-"git@github.com:magneticio"}

docker pull $build_server


if [ -z "${VAMP_GIT_BRANCH}" ]; then
  export VAMP_GIT_BRANCH=$((git -C ${root} branch || echo '* master' )  | grep '^\*' | sed -e 's/^\* //g')
fi

vamp_version=$1
if [ -z "${vamp_version}" ] ; then
  if [[ $( git -C ${root} describe --tags --abbrev=0 ) = $( git -C ${root} describe --tags ) ]] ; then
    vamp_version="$( git -C ${root} describe --tags )"
  else
    if [[ "$VAMP_GIT_BRANCH" != "" && "$VAMP_GIT_BRANCH" != "master" ]]; then
      vamp_version=${VAMP_GIT_BRANCH//\//_}
    else
      vamp_version="katana"
    fi
  fi
fi

target=${root}/target

function init_project() {
  local project=$1
  cd ${target}

  local url="${VAMP_GIT_ROOT}/${project}.git"
  local branch="master"

  local remotes=($(git ls-remote ${url} || echo fail))

  if [ "${remotes[0]}" != "fail" ]; then
    for x in "${remotes[@]}"; do
      if [ "${x}" = "refs/heads/${VAMP_GIT_BRANCH}" ]; then
        branch=${VAMP_GIT_BRANCH}
        break
      fi
    done
  else
    url="git@github.com:magneticio/${project}.git"
  fi

  echo "${green}project: ${yellow}${project} - ${url} - ${branch}${reset}"

  if [[ -d ${target}/${project} ]] ; then
    echo "${green}updating existing repository${reset}"

    cd ${target}/${project}

    git reset --hard
    git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    git fetch --depth=200 --prune
    git checkout ${branch}
    git reset --hard origin/${branch}
    git submodule sync --recursive
    git submodule update --init --recursive
  else
    git clone --recursive -b ${branch} --depth=200 "$url"
    cd ${target}/${project}
  fi

  if [ -f ${root}/Makefile.local ]; then
    cp -f ${root}/Makefile.local ${target}/${project}
  fi
  if [ -f ${root}/local.sh ]; then
    cp -f ${root}/local.sh ${target}/${project}
  fi
}

function build_project() {
  local project=$1
  make VERSION=${vamp_version} -C ${target}/${project}
}

function pack() {
  local project=$1
  init_project ${project}
  make -C ${target}/${project} pack
}

function build-vamp() {
  docker pull $(grep FROM ${root}/alpine-jdk/Dockerfile | cut -d ' ' -f2)
  (cd ${root} && ./build.sh --make --image=alpine-jdk)
  (cd ${root} && ./build.sh --build --version=${vamp_version} --image=vamp)
}

function build-clique() {
  docker pull $(grep FROM ${root}/clique-base/Dockerfile | cut -d ' ' -f2)
  for image in clique-base clique-zookeeper clique-zookeeper-marathon; do
    (cd ${root} && ./build.sh --build --version=${vamp_version} --image=${image})
  done
}

function build-agents() {
  init_project vamp-gateway-agent
  build_project vamp-gateway-agent
  init_project vamp-workflow-agent
  build_project vamp-workflow-agent
}
