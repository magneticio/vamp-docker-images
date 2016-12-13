#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

vamp_version=`cat ${dir}/version 2> /dev/null`

reset=`tput sgr0`
green=`tput setaf 2`
yellow=`tput setaf 3`

function push_vamp_image {
    echo "${green}pushing: ${yellow}magneticio/vamp:${vamp_version}$1${reset}"
    docker push magneticio/vamp:${vamp_version}$1
}

function push_vamp_images {
    regex="^${dir}\/(.+)\/Dockerfile$"

    for file in `find ${dir} | grep Dockerfile`
    do
      [[ ${file} =~ $regex ]] && [[ ${file} != *"/"* ]]
        image_dir="${BASH_REMATCH[1]}"

        if [[ ${image_dir} != *"/"* ]]; then

            if [[ "$image_dir" == vamp* ]]; then
                push_vamp_image ${image_dir:4}
            fi
        fi
    done
}

function push_quick_start_image {

    echo "${green}tagging ${yellow}magneticio/vamp-quick-start:${vamp_version}${green} to ${yellow}magneticio/vamp-docker:${vamp_version}${reset}"
    docker tag magneticio/vamp-quick-start:${vamp_version} magneticio/vamp-docker:${vamp_version}

    echo "${green}pushing ${yellow}magneticio/vamp-docker:${vamp_version}${reset}"
    docker push magneticio/vamp-docker:${vamp_version}

    echo "${green}removing ${yellow}magneticio/vamp-docker:${vamp_version}${reset}"
    docker rmi magneticio/vamp-docker:${vamp_version}
}

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗     ██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗    ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝    ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝     ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║         ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝         ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                                                     version ${vamp_version}
                                                                     by magnetic.io
${reset}"

flag_help=0
flag_vamp=0
flag_quick_start=0

for key in "$@"
do
case ${key} in
    -h|--help)
    flag_help=1
    ;;
    vamp|vamp/)
    flag_vamp=1
    ;;
    quick-start|quick-start/)
    flag_quick_start=1
    ;;
    *)
    ;;
esac
done

if [[ ${flag_vamp} -eq 0 && ${flag_quick_start} -eq 0 ]]; then
    flag_help=1
fi

if [ ${flag_help} -eq 1 ]; then
    echo "${green}Usage: $0 vamp|quick-start ${reset}"
    echo "${yellow}  vamp             ${green}Push all vamp* images.${reset}"
    echo "${yellow}  quick-start      ${green}Push quick-start image.${reset}"
    echo "${yellow}  -h  |--help      ${green}Help.${reset}"
    echo
fi

if [[ ${flag_vamp} -eq 1 ]]; then
    push_vamp_images
fi

if [[ ${flag_quick_start} -eq 1 ]]; then
    push_quick_start_image
fi

echo "${green}done.${reset}"
