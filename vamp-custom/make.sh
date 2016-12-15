#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
target=$1
mkdir -p ${target} && cd ${target}

cp -fR ${dir}/../artifacts ${target}/artifacts
cp -f ${dir}/Dockerfile ${target}/Dockerfile
cp -f ${dir}/vamp.sh ${target}/vamp.sh
