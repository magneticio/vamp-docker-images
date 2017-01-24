#!/usr/bin/env sh

project=$1

if [[ -z ${project} ]]; then
  echo "no project name provided"
  exit 1
fi

version=$2

if [[ -z ${version} ]]; then
  echo "no version name provided, using katana"
  version="katana"
fi

echo "project: ${project}"
echo "version: ${version}"

target="/usr/local/stash/${project}-${version}"

echo "pulling ${target} to /usr/local/dst"
cp -a ${target}/* /usr/local/dst/.