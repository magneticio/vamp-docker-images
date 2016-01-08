#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

vamp_version=0.8.2

reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`

flag_help=0
flag_clique_etcd=0
flag_clique_zookeeper=0
flag_clique_marathon=0
flag_quick_start=0
flag_quick_start_marathon=0

for key in "$@"
do
case ${key} in
    -h|--help)
    flag_help=1
    ;;
    clique-etcd)
    flag_clique_etcd=1
    ;;
    clique-etcd/)
    flag_clique_etcd=1
    ;;
    clique-zookeeper)
    flag_clique=1
    ;;
    clique-zookeeper/)
    flag_clique_zookeeper=1
    ;;
    clique-marathon)
    flag_clique_marathon=1
    ;;
    clique-marathon/)
    flag_clique_marathon=1
    ;;
    quick-start)
    flag_quick_start=1
    ;;
    quick-start/)
    flag_quick_start=1
    ;;
    quick-start-marathon)
    flag_quick_start_marathon=1
    ;;
    quick-start-marathon/)
    flag_quick_start_marathon=1
    ;;
    -v=*|--version=*)
    vamp_version="${key#*=}"
    shift
    ;;
    *)
    ;;
esac
done

export VAMP_VERSION=${vamp_version}

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝
                       version ${VAMP_VERSION}
                       by magnetic.io
${reset}"

error=0

if [[ ${flag_help} -eq 0 && ${flag_clique_etcd} -eq 0 && ${flag_clique_zookeeper} -eq 0 && ${flag_clique_marathon} -eq 0 && ${flag_quick_start} -eq 0 && ${flag_quick_start_marathon} -eq 0 ]]; then
    error=1
    echo "${red}No task specified.${reset}"
    echo
fi

task_count=$((${flag_clique_etcd} + ${flag_clique_zookeeper} + ${flag_clique_marathon} + ${flag_quick_start} + ${flag_quick_start_marathon}))
if [[ ${task_count} -gt 1 ]]; then
    error=1
    echo "${green}Must be specified only one task.${reset}"
    echo
fi

if [ ${flag_help} -eq 1 ] || [[ ${error} -ne 0 ]]; then
    echo "${green}Usage: $0 clique|clique-marathon|quick-start|quick-start-marathon [options] ${reset}"
    echo "${yellow}  clique-etcd          ${green}Run HAProxy, etcd, Elasticsearch, Logstash, Kibana and Vamp Gateway Agent.${reset}"
    echo "${yellow}  clique-zookeeper     ${green}Run HAProxy, ZooKeeper, Elasticsearch, Logstash, Kibana and Vamp Gateway Agent.${reset}"
    echo "${yellow}  clique-marathon      ${green}Run HAProxy, ZooKeeper, Elasticsearch, Logstash, Kibana, Vamp Gateway Agent, Mesos and Marathon.${reset}"
    echo "${yellow}  quick-start          ${green}Vamp without Marathon (i.e. Docker driver).${reset}"
    echo "${yellow}  quick-start-marathon ${green}Vamp with Marathon.${reset}"
    echo "${yellow}  -h  |--help          ${green}Help.${reset}"
    echo "${yellow}  -v=*|--version=*     ${green}Specifying Vamp version, e.g. -v=0.8.2${reset}"
    echo
    if [[ ${error} -ne 0 ]]; then
        exit ${error}
    fi
fi

target_dir=${dir}/"target"
compose_file=${target_dir}/compose.yml


function command_exists() {
	command -v "$@" > /dev/null 2>&1
}

if [[ ${flag_clique_etcd} -eq 1 ]]; then
    echo "${green}Running: clique-etcd${reset}"
    docker run --net=host -p 4001:4001 magneticio/vamp-clique-etcd:${vamp_version}
fi

if [[ ${flag_clique_zookeeper} -eq 1 ]]; then
    echo "${green}Running: clique-zookeeper${reset}"
    docker run --net=host magneticio/vamp-clique-zookeeper:${vamp_version}
fi

if [[ ${flag_clique_marathon} -eq 1 ]]; then
    echo "${green}Running: clique-marathon${reset}"

    if command_exists docker-machine; then
        DOCKER_HOST_IP=$(docker-machine ip default)
    else
        DOCKER_HOST_IP=$(hostname --ip-address)
    fi

    docker run --net=host \
               -v /var/run/docker.sock:/var/run/docker.sock \
               -v $(which docker):/bin/docker \
               -v "/sys/fs/cgroup:/sys/fs/cgroup" \
               -e "DOCKER_HOST_IP=${DOCKER_HOST_IP}" \
               magneticio/vamp-clique-marathon:0.8.2
fi

if [[ ${flag_quick_start} -eq 1 ]]; then
    echo "${green}Running: quick-start${reset}"

    if command_exists docker-machine; then
        docker run --net=host \
                   -v ~/.docker/machine/machines/default:/certs \
                   -e "DOCKER_TLS_VERIFY=1" \
                   -e "DOCKER_HOST=`docker-machine url default`" \
                   -e "DOCKER_CERT_PATH=/certs" \
                   magneticio/vamp-quick-start:${vamp_version}
    else
        docker run --net=host \
                   -v /var/run/docker.sock:/var/run/docker.sock \
                   -v $(which docker):/bin/docker \
                   magneticio/vamp-quick-start:${vamp_version}
    fi
fi

if [[ ${flag_quick_start_marathon} -eq 1 ]]; then
    echo "${green}Running: quick-start-marathon${reset}"

    docker run --net=host \
               -v /var/run/docker.sock:/var/run/docker.sock \
               -v $(which docker):/bin/docker \
               -v "/sys/fs/cgroup:/sys/fs/cgroup" \
               -e "DOCKER_HOST_IP=${DOCKER_HOST_IP}" \
               magneticio/vamp-quick-start-marathon:${vamp_version}
fi
