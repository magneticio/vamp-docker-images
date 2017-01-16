#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
target=$1
mkdir -p ${target} && cd ${target}

mkdir -p ${target}/artifacts/breeds ${target}/artifacts/blueprints ${target}/artifacts/workflows

curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/breeds/allocation.js -o ${target}/artifacts/breeds/allocation.js
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/breeds/health.js -o ${target}/artifacts/breeds/health.js
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/breeds/kibana.js -o ${target}/artifacts/breeds/kibana.js
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/breeds/metrics.js -o ${target}/artifacts/breeds/metrics.js

curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/blueprints/sava:1.0.yml -o ${target}/artifacts/blueprints/sava:1.0.yml
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/blueprints/sava:1.1.yml -o ${target}/artifacts/blueprints/sava:1.1.yml

curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/workflows/allocation.yml -o ${target}/artifacts/workflows/allocation.yml
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/workflows/health.yml -o ${target}/artifacts/workflows/health.yml
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/workflows/kibana.yml -o ${target}/artifacts/workflows/kibana.yml
curl https://raw.githubusercontent.com/magneticio/vamp-artifacts/master/workflows/metrics.yml -o ${target}/artifacts/workflows/metrics.yml


cp -f ${dir}/Dockerfile ${target}/Dockerfile
cp -f ${dir}/vamp.sh ${target}/vamp.sh
