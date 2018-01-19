#!/usr/bin/env bash

set -eu -o pipefail

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

VAMP_GIT_ROOT=${VAMP_GIT_ROOT:-"git@github.com:magneticio"}
VAMP_GIT_BRANCH=${VAMP_GIT_BRANCH:-"master"}

if [ "${RELEASE_TAG:=}" != "" ]; then
  VAMP_GIT_BRANCH="master"
  VAMP_GIT_ROOT="git@github.com:magneticio"
fi

pack() {
  local project=${1}

  local url="${VAMP_GIT_ROOT}/${project}.git"
  local branch="master"

  local sha ref
  while read sha ref; do
    if [ "${ref}" = "refs/heads/${VAMP_GIT_BRANCH}" ]; then
      branch=${VAMP_GIT_BRANCH}
      break
    fi
    if [ "${sha}" = "fail" ]; then
      url="git@github.com:magneticio/${project}.git"
      break
    fi
  done < <(git ls-remote ${url} || echo fail)

  echo "${green}project: ${yellow}${project} - ${url} - ${branch}${reset}"

  if [[ -d ${workspace}/${project}/.git ]] ; then
    echo "${green}updating existing repository${reset}"

    git -C ${workspace}/${project} reset --hard
    git -C ${workspace}/${project} config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    git -C ${workspace}/${project} fetch --depth=200 --prune
    git -C ${workspace}/${project} checkout ${branch}
    git -C ${workspace}/${project} reset --hard origin/${branch}
    git -C ${workspace}/${project} submodule sync --recursive
    git -C ${workspace}/${project} submodule update --init --recursive
  else
    rm -rf ${workspace}/${project}
    git clone --recursive -b ${branch} --depth=200 "$url" ${workspace}/${project}
  fi

  if [ -n "${VAMP_CHANGE_URL:=}" -a -z "${VAMP_CHANGE_URL/*\/${project}\/pull\/*/}" ]; then
    git  -C ${workspace}/${project} fetch --update-head-ok origin pull/${VAMP_CHANGE_URL/*\/${project}\/pull\//}/head:${branch} || \
    git  -C ${workspace}/${project} fetch --update-head-ok origin pull/${VAMP_CHANGE_URL/*\/${project}\/pull\//}/merge:${branch}
    git  -C ${workspace}/${project} reset --hard
  fi

  if [[ -f ${root}/Makefile.local ]]; then
    cp ${root}/Makefile.local ${workspace}/${project}/
  fi

  if [[ -f ${root}/local.sh ]]; then
    cp ${root}/local.sh ${workspace}/${project}/
  fi

  make -C ${workspace}/${project} pack
}

source ${root}/tests/build-conf.sh

for project in ${@:-${projects}}; do
  pack ${project}
done
