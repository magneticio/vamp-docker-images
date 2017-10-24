#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`
yellow=$(tput setaf 3)

build_server="magneticio/buildserver"
test -f ${dir}/local.sh && source ${dir}/local.sh

docker pull $build_server

[[ -n $1 ]] && target=$1 || { >&2 echo "missing input, exiting"; exit 1; }
mkdir -p ${target} && cd ${target}

if [[ $( git describe --tags --abbrev=0 ) = $( git describe --tags ) ]] ; then
  vamp_version="$( git describe --tags )"
else
  vamp_version="katana"
fi

: "${CLEAN_BUILD:=true}"

if [ "$CLEAN_BUILD" = "true" ]; then
  source ${dir}/../pack.sh
  rm -Rf ${target} && mkdir -p ${target} && cd ${target}
fi

function pull() {
  project=$1
  echo "${green}pulling project: ${yellow}${project}${reset}"
  mkdir ${target}/${project}

  docker volume create packer
  docker run \
    --rm \
    --volume "${target}/${project}":/usr/local/dst \
    --volume packer:/usr/local/stash \
    $build_server \
      pull "$project" "$vamp_version"
}

pull vamp
pull vamp-ui
pull vamp-lifter
pull vamp-lifter-ui
pull vamp-artifacts

cp -Rf ${dir}/files ${target}/
cp -f ${dir}/Dockerfile ${target}/
