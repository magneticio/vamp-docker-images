#!/usr/bin/env bash

set -e

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`
yellow=`tput setaf 3`

build_server="magneticio/buildserver"
dir_sbt=${HOME}/.sbt/boot
dir_ivy=${HOME}/.ivy2
test -f ${dir}/../local.sh && source ${dir}/../local.sh

metronome_version=0.2.2

docker pull $build_server

target=$1
mkdir -p ${target} && cd ${target}

echo "${green}building: ${yellow}metronome${reset}"

if [[ -d ${target}/metronome ]] ; then

  docker run \
    --rm \
    --volume ${target}:/srv/src \
    --workdir=/srv/src \
    $build_server \
      rm -rf /srv/src/metronome
fi

git clone https://github.com/dcos/metronome.git
cd ${target}/metronome
git checkout tags/v$metronome_version

docker run \
  --rm \
  --volume ${target}/metronome:/srv/src \
  --volume ${dir_sbt}:/home/vamp/.sbt/boot \
  --volume ${dir_ivy}:/home/vamp/.ivy2 \
  --workdir=/srv/src \
  --env BUILD_UID=$(id -u) \
  --env BUILD_GID=$(id -g) \
  $build_server \
    "sed -i 's/DEBUG/INFO/g' src/main/resources/logback.xml && sbt universal:packageBin"

mv $(find "${target}/metronome/target" -name 'metronome-*.zip' | sort | tail -1) ${target}/metronome.zip
echo "${green}copying files...${reset}"
cd ${dir}
cp -f ${dir}/chronos.sh ${target}
cp -f ${dir}/Dockerfile ${target}
cp -f ${dir}/marathon.sh ${target}
cp -f ${dir}/mesos-master.sh ${target}
cp -f ${dir}/mesos-slave.sh ${target}
cp -f ${dir}/supervisord.conf ${target}
