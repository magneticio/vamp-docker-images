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

VAMP_GIT_ROOT=${VAMP_GIT_ROOT:-"https://github.com/magneticio"}
VAMP_GIT_BRANCH=${VAMP_GIT_BRANCH:-"master"}

if [ "$RELEASE_TAG" != "" ]; then
  VAMP_GIT_BRANCH="master"
  VAMP_GIT_ROOT="https://github.com/magneticio"
fi

pack() {
  project=$1
  cd ${workspace}

  url="${VAMP_GIT_ROOT}/${project}.git"
  branch="master"

  remotes=($(git ls-remote ${url} || echo fail))

  if [ "${remotes[0]}" != "fail" ]; then
    for x in "${remotes[@]}"; do
      if [ "${x}" = "refs/heads/${VAMP_GIT_BRANCH}" ]; then
        branch=${VAMP_GIT_BRANCH}
        break
      fi
    done
  else
    url="https://github.com/magneticio/${project}.git"
  fi

  echo "${green}project: ${yellow}${project} - ${url} - ${branch}${reset}"

  if [[ -d ${workspace}/${project} ]] ; then
    echo "${green}updating existing repository${reset}"

    cd ${workspace}/${project}

    git reset --hard
    git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    git fetch --depth=200 --prune
    git checkout ${branch}
    git pull
    git submodule sync --recursive
    git submodule update --init --recursive
  else
    git clone --recursive -b ${branch} --depth=200 "$url"
    cd ${workspace}/${project}
  fi

  if [[ -f ${root}/Makefile.local ]]; then
    cp ${root}/Makefile.local ${workspace}/${project}/
  fi

  make pack
}

pack vamp
pack vamp-ui
pack vamp-lifter
pack vamp-lifter-ui
pack vamp-artifacts
