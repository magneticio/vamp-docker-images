#!/usr/bin/env bash

reset=`tput sgr0`
green=`tput setaf 2`
yellow=`tput setaf 3`
orange=`tput setaf 172`
red=$(tput setaf 1)
yellow=`tput setaf 3`

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

if [[ ( "$@" == "" ) || ( "$@" == "-h" ) || ( "$@" == "--help" ) ]]
then
  echo "${green}Usage: ${reset}"
  echo "${yellow}  quick-start                ${green}Pull quick-start ().${reset}"
  echo "${yellow}  vamp                       ${green}Pull vamp ().${reset}"
  echo "${yellow}  all | *                    ${green}Pull all images from magnetnicio repository.${reset}"
  echo "${yellow}  custom                     ${green}Interactive choosing images from magenticio repository.${reset}"
  echo "${yellow}  -h  |--help                ${green}Help.${reset}"
  exit
fi

if [[ "$@" == "quick-start" ]]
then
  ok "Pulling all quick-start images."

  # sava:
  step "Pulling magneticio/sava:1.0.0 image."
  docker pull magneticio/sava:1.0.0
  step "Pulling magneticio/sava:1.1.0 image."
  docker pull magneticio/sava:1.1.0
  ok "Pulled all sava images."

  # all agents
  step "Pulling magneticio/vamp-gateway-agent:katana image."
  docker pull magneticio/vamp-gateway-agent:katana
  step "Pulling magneticio/vamp-workflow-agent:katana image."
  docker pull magneticio/vamp-workflow-agent:katana
  ok "Pulled all agents."

  # runner
  step "Pulling magneticio/vamp-runner:katana image."
  docker pull magneticio/vamp-runner:katana
  ok "Pulled magneticio/vamp-runner:katana."

  # quick start
  step "Pulling magneticio/vamp:katana image."
  docker pull magneticio/vamp:katana
  ok "Pulled magneticio/vamp:katana."

  ok "Finished pulling all quick-start images."
  exit
fi

if [[ "$@" == "vamp" ]]
then
  # sava:
  step "Pulling magneticio/sava:1.0.0 image."
  docker pull magneticio/sava:1.0.0
  step "Pulling magneticio/sava:1.1.0 image."
  docker pull magneticio/sava:1.1.0
  ok "Pulled all sava images."

  # all agents
  step "Pulling magneticio/vamp-gateway-agent:katana image."
  docker pull magneticio/vamp-gateway-agent:katana
  step "Pulling magneticio/vamp-workflow-agent:katana image."
  docker pull magneticio/vamp-workflow-agent:katana
  ok "Pulled all agents."

  # runner
  step "Pulling magneticio/vamp-runner:katana image"
  docker pull magneticio/vamp-runner:katana
  ok "Pulled magneticio/vamp-runner:katana."

  ok "Finished pulling all vamp images."
  exit
fi

if [[ ( "$@" == "all" ) || ( "$@" == "*" ) ]]
then
  # all
  jq="$(command -v jq)" || { >&2 echo "${red}Error: jq not found!${reset}"; exit 1; }

  IMAGE_LIST=$(curl -s -S "https://registry.hub.docker.com/v2/repositories/magneticio/?page_size=100" | jq -r '.results|.[]|.name')

  function getAllVersionsOfImage() {
    step "Pulling all images of $1."
    docker pull --all-tags magneticio/$1
    ok "Done pulling all images of $1."
  }

  for IMAGE in ${IMAGE_LIST}
  do
    getAllVersionsOfImage ${IMAGE}
  done

  ok "Pull all images with all versions from magenticio repository."
  exit
fi

if [[ "$@" == "custom" ]]
then
  jq="$(command -v jq)" || { >&2 echo "${red}Error: jq not found!${reset}"; exit 1; }

  IMAGE_LIST=$(curl -s -S "https://registry.hub.docker.com/v2/repositories/magneticio/?page_size=100" | jq -r '.results|.[]|.name')

  N=0
  function listImages() {
    step "Listening all magneticio images:"
    echo "${N}. All katana versions"
    for IMAGE in ${IMAGE_LIST}
    do
      IMAGES[${N}]=${IMAGE}
      echo "${N}. magneticio:${IMAGE}"
      N=$(( N + 1 ))
    done
  }

  function getImage() {
    step "Retrieving ${IMAGES[${1}]}:${VERSIONS[${2}]}"
    docker pull magneticio/${IMAGES[${1}]}:${VERSIONS[${2}]}
    ok "Retrieved ${IMAGES[${1}]}:${VERSIONS[${2}]}"
  }

  V=0
  function listVersions() {
    step "Listing versions for magneticio/${IMAGES[${1}]}:"
    VERSION_LIST=$(curl -s -S "https://registry.hub.docker.com/v2/repositories/magneticio/${IMAGES[${1}]}/tags/?page_size=100" | jq -r '.results|.[]|.name')
    for VERSION in ${VERSION_LIST}
    do
      VERSIONS[${V}]=${VERSION}
      echo "${V}. ${IMAGES[${1}]}:${VERSION}"
      V=$(( V + 1))
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
  exit
fi

echo "${red}Error: Unkown command $@! Use -h or --help for instructions.${reset}"
