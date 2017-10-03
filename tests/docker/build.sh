#!/usr/bin/env bash

# Helper functions
export TERM=xterm # XXX: To get around 'tput: No value for $TERM and no -T specified'
info() { echo "$(date +%T): $(tput setaf 2)INFO:$(tput sgr0) $@"; }
warn() { echo "$(date +%T): $(tput setaf 3)WARN:$(tput sgr0) $@"; }
erro() { echo "$(date +%T): $(tput setaf 1)ERRO:$(tput sgr0) $@" >&2; }
errexit() { erro "$@"; erro "Exiting!"; exit 1; }

set -o errexit # Abort script at first error (command exits non-zero).

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
src_dir="../../target"

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗     ██████╗ ██╗   ██╗██╗██╗     ██████╗ ███████╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗    ██╔══██╗██║   ██║██║██║     ██╔══██╗██╔════╝██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝    ██████╔╝██║   ██║██║██║     ██║  ██║█████╗  ██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝     ██╔══██╗██║   ██║██║██║     ██║  ██║██╔══╝  ██╔══██╗
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║         ██████╔╝╚██████╔╝██║███████╗██████╔╝███████╗██║  ██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝         ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝
                                                                     by magnetic.io
${reset}"

workspace=${src_dir}
mkdir -p ${workspace}


VAMP_GIT_ROOT=${VAMP_GIT_ROOT:-"https://github.com/magneticio"}
VAMP_GIT_BRANCH=${VAMP_GIT_BRANCH:-"master"}

init_project() {
  # Download a git repository or update it to latest master or $VAMP_GIT_BRANCH, then add the
  # repository directory on top of the directory stack to continue work there
  local repo_url repo_dir
  [[ -n $1 ]] \
    && repo_url="$1" \
    || return 1

  [[ -n $2 ]] \
    && repo_dir="$2" \
    || repo_dir="$( basename $repo_url | sed 's/\.git$//' )"

  branch="master"

  check_url=$(curl -s -L -I ${repo_url} | grep HTTP | tail -n 1 | awk '{ print $2 }')

  if [ ${check_url} = "200" ]; then
    branch=$(git ls-remote ${repo_url} | awk '{ print $2 }' | grep -E "refs/heads/${VAMP_GIT_BRANCH}$" | sed -e "s/refs\/heads\///")
    branch=${branch:-"master"}
  else
    repo_url="https://github.com/magneticio/$(basename $repo_url)"
  fi

  info "Project '$repo_url' - ${branch} at '${src_dir}/${repo_dir}'"

  mkdir -p "$src_dir"

  if [[ -d ${src_dir}/${repo_dir} ]] ; then
    echo "${green}updating existing repository${reset}"

    cd "$src_dir/$repo_dir"

    git reset --hard
    git checkout ${branch}
    git pull
    cd -
  else
    cd "$src_dir"
    git clone -b ${branch} --depth=200 "$repo_url" "$repo_dir"
    cd -
  fi
}

build_external() {
  project=$1
  echo "${green}project: ${yellow}${project}${reset}"

  cd ${workspace}/${project}
  make
  cd -
}

build_ee() {
  project="vamp-ee"
  echo "${green}project: ${yellow}${project}${reset}"

  if [[ -d ${src_dir}/${project} ]] ; then
    echo "${green}updating existing repository${reset}"

    cd "$src_dir/$project"
    git reset --hard

    declare -i got_branch=$(git branch -a --list | grep -c " remotes/origin/${VAMP_GIT_BRANCH}$")
    if [  $got_branch -gt 0 ]; then
      git checkout ${VAMP_GIT_BRANCH}
      ./docker/local/make.sh - ${VAMP_GIT_BRANCH}
      ./docker/dcos/make.sh - ${VAMP_GIT_BRANCH}
    else
      git checkout
      ./docker/local/make.sh
      ./docker/dcos/make.sh
    fi

    git pull
    cd -
  else
    cd "$src_dir"
    local old_pwd=$OLDPWD
    git clone git@github.com:magneticio/vamp-ee.git "$project"
    cd ${project}
    declare -i got_branch=$(git branch -a --list | grep -c " remotes/origin/${VAMP_GIT_BRANCH}$")
    if [ $got_branch -gt 0 ]; then
      git checkout ${VAMP_GIT_BRANCH}
      ./docker/local/make.sh - ${VAMP_GIT_BRANCH}
      ./docker/dcos/make.sh - ${VAMP_GIT_BRANCH}
    else
      git checkout master
      ./docker/local/make.sh
      ./docker/dcos/make.sh
    fi
    cd $old_pwd
  fi
}

init_project ${VAMP_GIT_ROOT}/vamp-runner.git
init_project ${VAMP_GIT_ROOT}/vamp-gateway-agent.git
init_project ${VAMP_GIT_ROOT}/vamp-workflow-agent.git

# Disable the clean builds of various sub-build scripts
export CLEAN_BUILD=false


OLD_PWD=$PWD

cd ../..
source pack.sh
cd ${root}

./build.sh --build --image=vamp
./build.sh --build --image=vamp-custom
./build.sh --build --image=vamp-dcos
./build.sh --build --image=vamp-kubernetes


build_external vamp-gateway-agent
build_external vamp-workflow-agent
build_external vamp-runner


# Build the quick-start images
./build.sh --build --image=clique-base
./build.sh --build --image=clique-zookeeper
./build.sh --build --image=clique-zookeeper-marathon
./build.sh --build --image=quick-start

tag=$VAMP_GIT_BRANCH
if [ "$VAMP_GIT_BRANCH" = "master" ]; then
  tag="katana"
fi
docker tag "magneticio/vamp-quick-start:${tag}" "magneticio/vamp-docker:${tag}"

cd $OLD_PWD

export CLEAN_BUILD=true
build_ee
