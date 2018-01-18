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

test -f ${root}/../../local.sh && source ${root}/../../local.sh

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

  local sha ref
  while read sha ref; do
    if [ "${ref}" = "refs/heads/${VAMP_GIT_BRANCH}" ]; then
      branch=${VAMP_GIT_BRANCH}
      break
    fi
    if [ "${sha}" = "fail" ]; then
      repo_url="git@github.com:magneticio/$(basename $repo_url)"
      break
    fi
  done < <(git ls-remote ${repo_url} || echo fail)

  info "Project '$repo_url' - ${branch} at '${src_dir}/${repo_dir}'"

  mkdir -p "$src_dir"

  pushd .
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
  else
    cd "$src_dir"
    git clone --recursive -b ${branch} --depth=200 "$repo_url" "$repo_dir"
    cd "$repo_dir"
  fi

  if [ -n "${VAMP_CHANGE_URL}" -a -z "${VAMP_CHANGE_URL/*\/${repo_dir}\/pull\/*/}" ]; then
    git fetch --update-head-ok origin pull/${VAMP_CHANGE_URL/*\/${repo_dir}\/pull\//}/head:${branch} || \
    git fetch --update-head-ok origin pull/${VAMP_CHANGE_URL/*\/${repo_dir}\/pull\//}/merge:${branch}
    git reset --hard
  fi

  popd

  if [[ -f ${root}/../../Makefile.local ]]; then
    cp ${root}/../../Makefile.local ${src_dir}/${repo_dir}/
  fi

  if [[ -f ${root}/../../local.sh ]]; then
    cp ${root}/../../local.sh ${src_dir}/${repo_dir}/
  fi
}

build_external() {
  project=$1
  echo "${green}project: ${yellow}${project}${reset}"

  cd ${workspace}/${project}
  make
  cd -
}

init_project ${VAMP_GIT_ROOT}/vamp-gateway-agent.git
init_project ${VAMP_GIT_ROOT}/vamp-workflow-agent.git
init_project ${VAMP_GIT_ROOT}/vamp-docker-images-ee.git

# Disable the clean builds of various sub-build scripts
export CLEAN_BUILD=false


OLD_PWD=$PWD

cd ../..
./build.sh --make --image=alpine-jdk
source pack.sh

source ${workspace}/vamp-docker-images-ee/tests/build-conf.sh
for project in $ee_projects; do
  pack $project
done

cd ${root}

if [ "$VAMP_GIT_BRANCH" = "master" ]; then
  vamp_version="katana"
else
  vamp_version=${VAMP_GIT_BRANCH//\//_}
fi
vamp_version=${VAMP_TAG_PREFIX}${vamp_version}

./build.sh --build --version=${vamp_version} --image=vamp
./build.sh --build --version=${vamp_version} --image=vamp-custom
./build.sh --build --version=${vamp_version} --image=vamp-dcos
./build.sh --build --version=${vamp_version} --image=vamp-kubernetes

build_external vamp-gateway-agent
build_external vamp-workflow-agent

./build.sh --build --version=${vamp_version} --image=clique-base
./build.sh --build --version=${vamp_version} --image=clique-zookeeper
./build.sh --build --version=${vamp_version} --image=clique-zookeeper-marathon
./build.sh --build --version=${vamp_version} --image=quick-start
docker tag "magneticio/vamp-quick-start:${vamp_version}" "magneticio/vamp-docker:${vamp_version}"

for image in $ee_images; do
  cd ${workspace}/vamp-docker-images-ee/$image && ./build.sh ${vamp_version}
done
