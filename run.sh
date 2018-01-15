#! /usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

vamp_version=`cat ${dir}/version 2> /dev/null`

reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`

flag_help=0
flag_vga=0
flag_clique_etcd=0
flag_clique_consul=0
flag_clique_zookeeper=0
flag_clique_zookeeper_marathon=0
flag_quick_start=0

for key in "$@"
do
case ${key/\//} in
    -h|--help)
    flag_help=1
    ;;
    vga|vamp-gatewa-agent)
    flag_vga=1
    ;;
    clique-etcd)
    flag_clique_etcd=1
    ;;
    clique-consul)
    flag_clique_consul=1
    ;;
    clique-zookeeper)
    flag_clique_zookeeper=1
    ;;
    clique-zookeeper-marathon)
    flag_clique_zookeeper_marathon=1
    ;;
    quick-start)
    flag_quick_start=1
    quick_start_image=quick-start
    ;;
    vamp-docker)
    flag_quick_start=1
    quick_start_image=vamp-docker
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

if [[ ${flag_help} -eq 0&& ${flag_vga} -eq 0 && ${flag_clique_etcd} -eq 0 && ${flag_clique_consul} -eq 0 && ${flag_clique_zookeeper} -eq 0 && ${flag_clique_zookeeper_marathon} -eq 0 && ${flag_quick_start} -eq 0 ]]; then
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
    echo "${green}Usage: $0 vga|clique-*|quick-start [options] ${reset}"
    echo "${yellow}  vga (vamp-gateway-agent)   ${green}Run Vamp Gateway Agent.${reset}"
    echo "${yellow}  clique-etcd                ${green}Run HAProxy, etcd, Elasticsearch, Logstash and Kibana.${reset}"
    echo "${yellow}  clique-consul              ${green}Run HAProxy, Consul, Elasticsearch, Logstash and Kibana.${reset}"
    echo "${yellow}  clique-zookeeper           ${green}Run HAProxy, ZooKeeper, Elasticsearch, Logstash and Kibana.${reset}"
    echo "${yellow}  clique-zookeeper-marathon  ${green}Run all from 'clique-zookeeper' and Mesos, Marathon and Chronos.${reset}"
    echo "${yellow}  quick-start                ${green}Vamp quick start with Marathon.${reset}"
    echo "${yellow}  -h  |--help                ${green}Help.${reset}"
    echo "${yellow}  -v=*|--version=*           ${green}Specifying Vamp version, e.g. -v=${vamp_version}${reset}"
    echo
    if [[ ${error} -ne 0 ]]; then
        exit ${error}
    fi
fi

if [[ ${flag_vga} -eq 1 ]]; then
    echo "${green}Running: vamp-gateway-agent${reset}"
    docker run -d --name=vamp_vga \
               --net=${VGA_NETWORK:-host} \
               --privileged \
               -e VAMP_GATEWAY_AGENT_LOGO=0 \
               -e VAMP_KEY_VALUE_STORE_TYPE=zookeeper \
               -e VAMP_KEY_VALUE_STORE_CONNECTION=${DOCKER_HOST_IP:-172.17.0.1}:2181 \
               -e VAMP_KEY_VALUE_STORE_PATH=/vamp/vamp/gateways/haproxy/1.7/configuration \
               -e VAMP_ELASTICSEARCH_URL=http://${DOCKER_HOST_IP:-172.17.0.1}:9200 \
               magneticio/vamp-gateway-agent:${vamp_version}
fi

if [[ ${flag_clique_etcd} -eq 1 ]]; then
    echo "${green}Running: clique-etcd${reset}"
    docker run -d --name=vamp_clique-etcd \
               --net=host \
               --security-opt=seccomp:unconfined \
               -v /var/run/docker.sock:/var/run/docker.sock \
               -v /sys/fs/cgroup:/sys/fs/cgroup \
               magneticio/vamp-clique-etcd:${vamp_version}
fi

if [[ ${flag_clique_consul} -eq 1 ]]; then
    echo "${green}Running: clique-consul${reset}"
    docker run -d --name=vamp_clique-consul \
               --net=host \
               --security-opt=seccomp:unconfined \
               -v /var/run/docker.sock:/var/run/docker.sock \
               -v /sys/fs/cgroup:/sys/fs/cgroup \
               magneticio/vamp-clique-consul:${vamp_version}
fi

if [[ ${flag_clique_zookeeper} -eq 1 ]]; then
    echo "${green}Running: clique-zookeeper${reset}"
    docker run -d --name=vamp_clique-zookeeper \
               -v /var/run/docker.sock:/var/run/docker.sock \
               -v /sys/fs/cgroup:/sys/fs/cgroup \
               -p 5050:5050 \
               -p 8989:8989 \
               -p 9200:9200 \
               -p 9300:9300 \
               -p 2181:2181 \
               magneticio/vamp-clique-zookeeper:${vamp_version}
fi

if [[ ${flag_clique_zookeeper_marathon} -eq 1 ]]; then
    echo "${green}Running: clique-zookeeper-marathon${reset}"

    docker run -d --name=vamp_clique-zookeeper-marathon \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /sys/fs/cgroup:/sys/fs/cgroup \
           -e DOCKER_HOST_IP=${DOCKER_HOST_IP:-172.17.0.1} \
           -p 5050:5050 \
           -p 5051:5051 \
           -p 5052:5052 \
           -p 9090:9090 \
           -p 8989:8989 \
           -p 4400:4400 \
           -p 9200:9200 \
           -p 9300:9300 \
           -p 5601:5601 \
           -p 2181:2181 \
           magneticio/vamp-clique-zookeeper-marathon:${vamp_version}
fi

if [[ ${flag_quick_start} -eq 1 ]]; then
    echo "${green}Running: quick-start${reset}"

    docker run -d --name=vamp_quick-start \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /sys/fs/cgroup:/sys/fs/cgroup \
           -e DOCKER_HOST_IP=${DOCKER_HOST_IP:-172.17.0.1} \
           -p 8080:8080 \
           -p 8081:8081 \
           -p 5050:5050 \
           -p 5051:5052 \
           -p 5052:5052 \
           -p 9090:9090 \
           -p 8989:8989 \
           -p 4400:4400 \
           -p 9200:9200 \
           -p 9300:9300 \
           -p 5601:5601 \
           -p 2181:2181 \
           magneticio/${quick_start_image}:${vamp_version}
fi
