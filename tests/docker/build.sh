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


VAMP_GIT_ROOT=${VAMP_GIT_ROOT:-"git@github.com:magneticio"}
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

  remotes=($(git ls-remote ${repo_url} || echo fail))

  if [ "${remotes[0]}" != "fail" ]; then
    for x in "${remotes[@]}"; do
      if [ "${x}" = "refs/heads/${VAMP_GIT_BRANCH}" ]; then
        branch=${VAMP_GIT_BRANCH}
        break
      fi
    done
  else
    repo_url="git@github.com:magneticio/$(basename $repo_url)"
  fi

  info "Project '$repo_url' - ${branch} at '${src_dir}/${repo_dir}'"

  mkdir -p "$src_dir"

  if [[ -d ${src_dir}/${repo_dir} ]] ; then
    echo "${green}updating existing repository${reset}"

    cd "$src_dir/$repo_dir"

    git reset --hard
    git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    git fetch --depth=200 --prune
    git checkout ${branch}
    git reset --hard origin/${branch}
    git submodule sync --recursive
    git submodule update --init --recursive
    cd -
  else
    cd "$src_dir"
    git clone --recursive -b ${branch} --depth=200 "$repo_url" "$repo_dir"
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

init_project ${VAMP_GIT_ROOT}/vamp-runner.git
init_project ${VAMP_GIT_ROOT}/vamp-gateway-agent.git
init_project ${VAMP_GIT_ROOT}/vamp-workflow-agent.git
init_project ${VAMP_GIT_ROOT}/vamp-docker-images-ee.git

# Disable the clean builds of various sub-build scripts
export CLEAN_BUILD=false


OLD_PWD=$PWD

cd ../..
source pack.sh
# Pack ee projects
pack vamp-ee
pack vamp-ee-ui
pack vamp-vault
pack vamp-ee-lifter
pack vamp-ee-lifter-ui
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

tag=${VAMP_GIT_BRANCH//\//_}
if [ "$VAMP_GIT_BRANCH" = "master" ]; then
  tag="katana"
fi
docker tag "magneticio/vamp-quick-start:${tag}" "magneticio/vamp-docker:${tag}"

cd ${workspace}/vamp-docker-images-ee/vamp-ee && ./build.sh $tag
cd ${workspace}/vamp-docker-images-ee/vamp-ee-lifter && ./build.sh $tag

cd $OLD_PWD
