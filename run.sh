#! /usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

vamp_version=`cat ${dir}/version 2> /dev/null`

reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`

flag_help=0
flag_clique_etcd=0
flag_clique_consul=0
flag_clique_zookeeper=0
flag_clique_zookeeper_marathon=0
flag_quick_start=0

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
    clique-consul)
    flag_clique_consul=1
    ;;
    clique-consul/)
    flag_clique_consul=1
    ;;
    clique-zookeeper)
    flag_clique_zookeeper=1
    ;;
    clique-zookeeper/)
    flag_clique_zookeeper=1
    ;;
    clique-zookeeper-marathon)
    flag_clique_zookeeper_marathon=1
    ;;
    clique-zookeeper-marathon/)
    flag_clique_zookeeper_marathon=1
    ;;
    quick-start)
    flag_quick_start=1
    ;;
    quick-start/)
    flag_quick_start=1
    ;;
    -v=*|--version=*)
    vamp_version="${key#*=}"
    shift
    ;;
    *)
    ;;
esac
done

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

error=0

if [[ ${flag_help} -eq 0 && ${flag_clique_etcd} -eq 0 && ${flag_clique_consul} -eq 0 && ${flag_clique_zookeeper} -eq 0 && ${flag_clique_zookeeper_marathon} -eq 0 && ${flag_quick_start} -eq 0 ]]; then
    error=1
    echo "${red}No task specified.${reset}"
    echo
fi

task_count=$((${flag_clique_etcd} + ${flag_clique_consul} + ${flag_clique_zookeeper} + ${flag_clique_zookeeper_marathon} + ${flag_quick_start}))
if [[ ${task_count} -gt 1 ]]; then
    error=1
    echo "${green}Must be specified only one task.${reset}"
    echo
fi

if [ ${flag_help} -eq 1 ] || [[ ${error} -ne 0 ]]; then
    echo "${green}Usage: $0 clique-*|quick-start [options] ${reset}"
    echo "${yellow}  clique-etcd                ${green}Run HAProxy, etcd, Elasticsearch, Logstash, Kibana and Vamp Gateway Agent.${reset}"
    echo "${yellow}  clique-consul              ${green}Run HAProxy, Consul, Elasticsearch, Logstash, Kibana and Vamp Gateway Agent.${reset}"
    echo "${yellow}  clique-zookeeper           ${green}Run HAProxy, ZooKeeper, Elasticsearch, Logstash, Kibana and Vamp Gateway Agent.${reset}"
    echo "${yellow}  clique-zookeeper-marathon  ${green}Run all from 'clique-zookeeper' and Mesos, Marathon and Chronos.${reset}"
    echo "${yellow}  quick-start                ${green}Vamp quick start with Marathon.${reset}"
    echo "${yellow}  -h  |--help                ${green}Help.${reset}"
    echo "${yellow}  -v=*|--version=*           ${green}Specifying Vamp version, e.g. -v=${vamp_version}${reset}"
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

# Return the first IP address in the bridge network by incrementing the 4th
# octet of the gateway IP
function get_docker_host_ip() {
  case "$( uname -s )" in
    Linux)
      hostname -I | awk '{ print $1}'
      # docker network inspect bridge \
      #   --format "{{ (index .IPAM.Config 0).Gateway  }}" \
      #     | awk -F'.' '{ print $1 "." $2 "." $3 "." ( $4 += 1 ) }'
      ;;
    Darwin)
      echo "192.168.65.2" # docker-machine ip default
      ;;
  esac
}

if [[ ${flag_clique_etcd} -eq 1 ]]; then
    echo "${green}Running: clique-etcd${reset}"
    docker run --net=host \
               --security-opt=seccomp:unconfined \
               -v /var/run/docker.sock:/var/run/docker.sock \
               -v $(which docker):/bin/docker \
               -v "/sys/fs/cgroup:/sys/fs/cgroup" \
               magneticio/vamp-clique-etcd:${vamp_version}
fi

if [[ ${flag_clique_consul} -eq 1 ]]; then
    echo "${green}Running: clique-consul${reset}"
    docker run --net=host \
               --security-opt=seccomp:unconfined \
               -v /var/run/docker.sock:/var/run/docker.sock \
               -v $(which docker):/bin/docker \
               -v "/sys/fs/cgroup:/sys/fs/cgroup" \
               magneticio/vamp-clique-consul:${vamp_version}
fi

if [[ ${flag_clique_zookeeper} -eq 1 ]]; then
    echo "${green}Running: clique-zookeeper${reset}"
    docker run --net=host \
               --security-opt=seccomp:unconfined \
               -v /var/run/docker.sock:/var/run/docker.sock \
               -v $(which docker):/bin/docker \
               -v "/sys/fs/cgroup:/sys/fs/cgroup" \
               magneticio/vamp-clique-zookeeper:${vamp_version}
fi

if [[ ${flag_clique_zookeeper_marathon} -eq 1 ]]; then
    echo "${green}Running: clique-zookeeper-marathon${reset}"

    DOCKER_HOST_IP="$( get_docker_host_ip )"

    docker run -v /var/run/docker.sock:/var/run/docker.sock \
           -v /usr/bin/docker:/bin/docker \
           -v "/sys/fs/cgroup:/sys/fs/cgroup" \
           -e "DOCKER_HOST_IP=${DOCKER_HOST_IP}" \
           -p 5050:5050 \
           -p 8090:9090 \
           -p 8989:8989 \
           -p 4400:4400 \
           -p 9200:9200 \
           -p 5601:5601 \
           -p 2181:2181 \
           magneticio/vamp-clique-zookeeper-marathon:${vamp_version}
fi

if [[ ${flag_quick_start} -eq 1 ]]; then
    echo "${green}Running: quick-start${reset}"

    DOCKER_HOST_IP="$( get_docker_host_ip )"

    docker run -v /var/run/docker.sock:/var/run/docker.sock \
           -v /usr/bin/docker:/bin/docker \
           -v "/sys/fs/cgroup:/sys/fs/cgroup" \
           -e "DOCKER_HOST_IP=${DOCKER_HOST_IP}" \
           -p 8080:8080 \
           -p 5050:5050 \
           -p 9090:9090 \
           -p 8989:8989 \
           -p 4400:4400 \
           -p 9200:9200 \
           -p 5601:5601 \
           -p 2181:2181 \
           magneticio/vamp-quick-start:${vamp_version}
fi
