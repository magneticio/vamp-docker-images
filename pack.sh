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

if [ "${RELEASE_TAG:=}" != "" ]; then
  export VAMP_GIT_BRANCH="master"
  export VAMP_GIT_ROOT="git@github.com:magneticio"
else
  export VAMP_GIT_ROOT=${VAMP_GIT_ROOT:-"git@github.com:magneticio"}
  export VAMP_GIT_BRANCH=${VAMP_GIT_BRANCH:-"master"}
fi

source "${root}"/tests/build-conf.sh
MAKE_TARGET=pack "${root}"/make.sh ${projects} ${ui_projects}
