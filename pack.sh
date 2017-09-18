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

  check_url=$(curl -m 5 -s -L -I ${url} | grep HTTP | tail -n 1 | awk '{ print $2 }')

  if [ "${check_url}" = "200" ]; then
    branch=$(git ls-remote ${url} | awk '{ print $2 }' | grep -E "refs/heads/${VAMP_GIT_BRANCH}$" | sed -e "s/refs\/heads\///")
    branch=${branch:-"master"}
  else
    url="https://github.com/magneticio/${project}.git"
  fi

  echo "${green}project: ${yellow}${project} - ${url} - ${branch}${reset}"

  if [[ -d ${workspace}/${project} ]] ; then
    echo "${green}updating existing repository${reset}"

    cd ${workspace}/${project}

    git reset --hard
    git checkout ${branch}
    git pull
  else
    git clone -b ${branch} --depth=200 "$url"
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
