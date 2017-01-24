#!/usr/bin/env sh

project=$1

if [[ -z ${project} ]]; then
  echo "no project name provided"
  exit 1
fi

version=$2

if [[ -z ${version} ]]; then
  echo "no version name provided"
  exit 1
fi

echo "project: ${project}"
echo "version: ${version}"

if [ ! "$(ls -A /usr/local/src)" ]; then
  echo "nothing to be stashed"
  exit 0
fi

target="/usr/local/stash/${project}-${version}"
katana="/usr/local/stash/${project}-katana"

echo "stashing /usr/local/src as ${target}"

rm -Rf ${target} && mkdir -p ${target}
cp -a "/usr/local/src/." "${target}/"
rm -Rf ${katana} && ln -s ${target} ${katana}
