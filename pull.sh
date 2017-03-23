#!/usr/bin/env bash

reset=`tput sgr0`
green=`tput setaf 2`
yellow=`tput setaf 3`
orange=`tput setaf 172`
red=$(tput setaf 1)

step() {
    echo "${yellow}[STEP] $1${reset}"
}

ok() {
    echo "${green}[OK] $1${reset}"
}

ask() {
  echo "${orange}[Question] $1${reset}"
}


echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗     ██╗███╗   ███╗ █████╗  ██████╗ ███████╗███████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗    ██║████╗ ████║██╔══██╗██╔════╝ ██╔════╝██╔════╝
██║   ██║███████║██╔████╔██║██████╔╝    ██║██╔████╔██║███████║██║  ███╗█████╗  ███████╗
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝     ██║██║╚██╔╝██║██╔══██║██║   ██║██╔══╝  ╚════██║
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║         ██║██║ ╚═╝ ██║██║  ██║╚██████╔╝███████╗███████║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝         ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝

                                                                         by magnetic.io
${reset}"

figlet="$(command -v jq)" || { >&2 echo "${red}Error: jq not found!${reset}"; exit 1; }

IMAGE_LIST=$(curl -s -S "https://registry.hub.docker.com/v2/repositories/magneticio/?page_size=100" | jq -r '.results|.[]|.name')

N=0

function listImages() {
  step "Listening all magneticio images:"
  echo "${N}. All katana versions"
  for IMAGE in ${IMAGE_LIST}
  do
    N=$(( N + 1 ))
    IMAGES[${N}]=${IMAGE}
    echo "${N}. magneticio:${IMAGE}"
  done
}

function getImage() {
  step "Retrieving ${IMAGES[${1}]}:${VERSIONS[${2}]}"
  docker pull magneticio/${IMAGES[${1}]}:${VERSIONS[${2}]}
  ok "Retrieved ${IMAGES[${1}]}:${VERSIONS[${2}]}"
}

function getAllKatanaImages() {
  ok "Retrieving all magneticio/vamp:katana images"
  step "Retrieving magneticio/vamp:katana-rancher"
  docker pull magneticio/vamp:katana-rancher
  step "Retrieving magneticio/vamp:katana-kubernetes"
  docker pull magneticio/vamp:katana-kubernetes
  step "Retrieving magneticio/vamp:katana-dcos"
  docker pull magneticio/vamp:katana-dcos
  step "Retrieving magneticio/vamp:katana-custom"
  docker pull magneticio/vamp:katana-custom
  step "Retrieving magneticio/vamp:katana"
  docker pull magneticio/vamp:katana
  step "Retrieving magneticio/vamp:katana-aws"
  docker pull magneticio/vamp:katana-aws
  ok "Retrieved all magneticio/vamp:katana images"
}

v=0
function listVersions() {
  step "Listing versions for magneticio/${IMAGES[${1}]}:"
  VERSION_LIST=$(curl -s -S "https://registry.hub.docker.com/v2/repositories/magneticio/${IMAGES[${1}]}/tags/?page_size=100" | jq -r '.results|.[]|.name')
  for VERSION in ${VERSION_LIST}
  do
    V=$(( V + 1))
    VERSIONS[${V}]=${VERSION}
    echo "${V}. ${IMAGES[${1}]}:${VERSION}"
  done
}

listImages

ask "Choose the number of the image you want to pull: "
read
IMAGE_REPLY=$REPLY

if [[ $REPLY == 0 ]]
then
  getAllKatanaImages
else
  listVersions $IMAGE_REPLY
  ask "Choose the number of the version you want to pull: "
  read
  VERSION_REPLY=$REPLY
  getImage $IMAGE_REPLY $VERSION_REPLY
fi
