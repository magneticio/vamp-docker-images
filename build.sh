#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`

vamp_version="0.8.2"
target='target/docker'

cd ${dir}

function parse_command_line() {
    flag_help=0
    flag_list=0
    flag_clean=0
    flag_make=0
    flag_build=0

    for key in "$@"
    do
    case ${key} in
        -h|--help)
        flag_help=1
        ;;
        -l|--list)
        flag_list=1
        ;;
        -c|--clean)
        flag_clean=1
        ;;
        -m|--make)
        flag_make=1
        ;;
        -b|--build)
        flag_make=1
        flag_build=1
        ;;
        -v=*|--version=*)
        vamp_version="${key#*=}"
        shift
        ;;
        -i=*|--image=*)
        target_image="${key#*=}"
        length=${#target_image}
        ((length--))
        if [ "${target_image:$length:1}" == "/" ]; then
            target_image="${target_image%?}"
        fi
        shift
        ;;
        *)
        ;;
    esac
    done
}

function print_help() {
    echo "${green}Usage of $0:${reset}"
    echo "${yellow}  -h  |--help       ${green}Help.${reset}"
    echo "${yellow}  -l  |--list       ${green}List all available and built images.${reset}"
    echo "${yellow}  -c  |--clean      ${green}Remove all available images.${reset}"
    echo "${yellow}  -m  |--make       ${green}Copy all available Docker files to '${target}' directory.${reset}"
    echo "${yellow}  -b  |--build      ${green}Build all available images.${reset}"
    echo "${yellow}  -v=*|--version=*  ${green}Specifying Vamp version, e.g. -v=0.8.2${reset}"
    echo "${yellow}  -i=*|--image=*    ${green}Specifying single image to be processed, e.g. -i=marathon${reset}"
}

function docker_rmi {
    echo "${green}removing docker image: $1 ${reset}"
    docker rmi -f $1 2> /dev/null
}

function docker_make {
    make_file=${dir}/$1/make.sh
    if [ -f "${make_file}" ]
    then
        echo "${green}executing make.sh from $1 ${reset}"
        bash ${dir}/$1/make.sh ${dir}/${target}/$1
        exit_code=$?
        if [ ${exit_code} != 0 ]; then
            echo "${red}make.sh failed with code: ${exit_code}${reset}"
            exit ${exit_code}
        fi
    else
        echo "${green}copying files from: $1 ${reset}"
        cp -R ${dir}/$1 ${target} 2> /dev/null
        rm -f ${target}/$1/version 2> /dev/null
    fi
}

function docker_build {
    echo "${green}building docker image: $1 ${reset}"
    docker build -t $1 $2
}

function docker_images {
    arr=$1[@]
    images=("${!arr}")
    pattern=$(printf "\|%s" "${images[@]}")
    pattern=${pattern:2}
    echo "${green}available images:${yellow}"
    for image in "${images[@]}"
    do
      echo ${image}:${vamp_version}
    done
    echo "${green}built images    :${yellow}"
    docker images | grep 'magneticio/vamp' | grep ${pattern} | grep ${vamp_version}
}

function process() {
    regex="^${dir}\/(.+)\/Dockerfile$"
    images=()

    find_in=${dir}
    if [ -n "${target_image}" ]; then
        find_in=${dir}/${target_image}
    fi

    for file in `find ${find_in} | grep Dockerfile`
    do
      [[ ${file} =~ $regex ]] && [[ ${file} != *"/"* ]]
        image_dir="${BASH_REMATCH[1]}"

        if [[ ${image_dir} != *"/"* ]]; then

            target_version=`cat ${dir}/${image_dir}/version 2> /dev/null`

            if [ "$target_version" ]; then
                image=magneticio/vamp-${image_dir}-${target_version}
            else
                image=magneticio/vamp-${image_dir}
            fi

            images+=(${image})
            image_name=${image}:${vamp_version}

            if [ ${flag_make} -eq 1 ]; then
                docker_make ${image_dir}
            fi
            if [ ${flag_clean} -eq 1 ]; then
                docker_rmi ${image_name}
            fi
            if [ ${flag_build} -eq 1 ]; then
                docker_build ${image_name} ${dir}/${target}/${image_dir}
            fi
        fi
    done

    if [ ${flag_list} -eq 1 ]; then
        docker_images images
    fi

    echo "${green}done.${reset}"
}

parse_command_line $@

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝
                       version ${vamp_version}
                       by magnetic.io
${reset}"

if [ ${flag_help} -eq 1 ] || [[ $# -eq 0 ]]; then
    print_help
fi

if [ ${flag_list} -eq 1 ] || [ ${flag_clean} -eq 1 ] || [ ${flag_make} -eq 1 ] || [ ${flag_build} -eq 1 ]; then
    rm -Rf ${dir}/${target} 2> /dev/null && mkdir -p ${target}
    process
fi
