#!/usr/bin/env bash

set -eu -o pipefail

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
workspace="${root}/../../target"

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

mkdir -p ${workspace}

init_project() {
  local repo_url=${1}
  local repo_dir="$(basename $repo_url | sed 's/\.git$//')"
  local branch="master"

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

  info "Project '${repo_url}' - ${branch} at '${workspace}/${repo_dir}'"

  if [ -d ${workspace}/${repo_dir}/.git ] ; then
    echo "${green}updating existing repository${reset}"

    git -C "${workspace}/${repo_dir}" reset --hard
    git -C "${workspace}/${repo_dir}" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    git -C "${workspace}/${repo_dir}" fetch --depth=200 --prune
    git -C "${workspace}/${repo_dir}" checkout ${branch}
    git -C "${workspace}/${repo_dir}" reset --hard origin/${branch}
    git -C "${workspace}/${repo_dir}" submodule sync --recursive
    git -C "${workspace}/${repo_dir}" submodule update --init --recursive
  else
    git clone --recursive -b ${branch} --depth=200 "${repo_url}" "${workspace}/${repo_dir}"
  fi

  if [ -n "${VAMP_CHANGE_URL:=}" -a -z "${VAMP_CHANGE_URL/*\/${repo_dir}\/pull\/*/}" ]; then
    git -C "${workspace}/${repo_dir}" fetch --update-head-ok origin pull/${VAMP_CHANGE_URL/*\/${repo_dir}\/pull\//}/head:${branch} || \
    git -C "${workspace}/${repo_dir}" fetch --update-head-ok origin pull/${VAMP_CHANGE_URL/*\/${repo_dir}\/pull\//}/merge:${branch}
    git -C "${workspace}/${repo_dir}" reset --hard
  fi

  if [[ -f ${root}/../../Makefile.local ]]; then
    cp ${root}/../../Makefile.local ${workspace}/${repo_dir}/
  fi

  if [[ -f ${root}/../../local.sh ]]; then
    cp ${root}/../../local.sh ${workspace}/${repo_dir}/
  fi
}

build_external() {
  project=$1
  echo "${green}project: ${yellow}${project}${reset}"
  make -C ${workspace}/${project}
}

init_project ${VAMP_GIT_ROOT}/vamp-docker-images-ee.git

init_project ${VAMP_GIT_ROOT}/vamp-gateway-agent.git
init_project ${VAMP_GIT_ROOT}/vamp-workflow-agent.git

build_external vamp-gateway-agent
build_external vamp-workflow-agent

source ${root}/../build-conf.sh
source ${workspace}/vamp-docker-images-ee/tests/build-conf.sh

${root}/../../build.sh --make --image=alpine-jdk
${root}/../../pack.sh ${projects} ${ee_projects}

${root}/../../build.sh --build --version=${VAMP_VERSION} --image=vamp
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=vamp-custom
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=vamp-dcos
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=vamp-kubernetes

${root}/../../build.sh --build --version=${VAMP_VERSION} --image=clique-base
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=clique-zookeeper
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=clique-zookeeper-marathon
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=quick-start
docker tag "magneticio/vamp-quick-start:${VAMP_VERSION}" "magneticio/vamp-docker:${VAMP_VERSION}"

for image in $ee_images; do
  ${workspace}/vamp-docker-images-ee/$image/build.sh ${VAMP_VERSION}
done
