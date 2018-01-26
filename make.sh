#!/usr/bin/env bash

set -eu -o pipefail

function get-root-dir() {
  local dir=$(dirname "${BASH_SOURCE[0]}")
  (cd "${dir}" && pwd)
}

root="$(get-root-dir)"
workspace="${root}"/target
mkdir -p "${workspace}"

function build() {
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

  if [[ -d "${workspace}"/${project}/.git ]] ; then
    git -C "${workspace}"/${project} config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    git -C "${workspace}"/${project} reset --hard
    git -C "${workspace}"/${project} fetch --depth=200 --prune
    git -C "${workspace}"/${project} checkout ${branch}
    git -C "${workspace}"/${project} reset --hard origin/${branch}
    git -C "${workspace}"/${project} submodule sync --recursive
    git -C "${workspace}"/${project} submodule update --init --recursive
  else
    rm -rf "${workspace}"/${project}
    git clone --recursive -b ${branch} --depth=200 "$url" "${workspace}"/${project}
  fi

  if [ -n "${VAMP_CHANGE_URL:=}" -a -z "${VAMP_CHANGE_URL/*\/${project}\/pull\/*/}" ]; then
    git  -C "${workspace}"/${project} fetch --update-head-ok origin pull/${VAMP_CHANGE_URL/*\/${project}\/pull\//}/head:${branch} || \
    git  -C "${workspace}"/${project} fetch --update-head-ok origin pull/${VAMP_CHANGE_URL/*\/${project}\/pull\//}/merge:${branch}
    git  -C "${workspace}"/${project} reset --hard
  fi

  if [[ -f "${root}"/Makefile.local ]]; then
    cp "${root}"/Makefile.local "${workspace}"/${project}/
  fi

  if [[ -f "${root}"/local.sh ]]; then
    cp "${root}"/local.sh "${workspace}"/${project}/
  fi

  if [ "${MAKE_TARGET:=}" != "none" ]; then
    ${MAKE:-make} -C "${workspace}"/${project} ${MAKE_TARGET:=}
  fi
}

for project in ${@}; do
  build ${project}
done
