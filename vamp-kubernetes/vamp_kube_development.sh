#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

: "${NAMESPACE:=default}"
: "${VGA_YAML:=${dir}/vga.yml}"
: "${ETCD_YAML:=${dir}/etcdDevelopment.yml}"
: "${ELASTICSEARCH_IMAGE:=elasticsearch:2.4.4}"
: "${KIBANA_IMAGE:=kibana:4.6.4}"

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

echo "${green}
╦  ╦╔═╗╔╦╗╔═╗  ╦╔═╦ ╦╔╗ ╔═╗╦═╗╔╗╔╔═╗╔╦╗╔═╗╔═╗
╚╗╔╝╠═╣║║║╠═╝  ╠╩╗║ ║╠╩╗║╣ ╠╦╝║║║║╣  ║ ║╣ ╚═╗
 ╚╝ ╩ ╩╩ ╩╩    ╩ ╩╚═╝╚═╝╚═╝╩╚═╝╚╝╚═╝ ╩ ╚═╝╚═╝

Development Environment Installation.
${reset}"

if [ `kubectl config current-context` = "minikube" ]; then
  flag_minikube=1
else
  flag_minikube=0
fi

if [ ${flag_minikube} -eq 1 ]; then
    echo "${green}minikube  : ${yellow}yes${reset}"
fi

echo "${green}namespace           : ${yellow}$NAMESPACE${reset}"
echo "${green}vga file            : ${yellow}$VGA_YAML${reset}"
echo "${green}etcd file           : ${yellow}$ETCD_YAML${reset}"
echo "${green}Elasticsearch image : ${yellow}$ELASTICSEARCH_IMAGE${reset}"
echo "${green}Kibana image        : ${yellow}$KIBANA_IMAGE${reset}"
echo

error() {
    echo "${red}[ERROR] $1${reset}"
    echo
    exit 1
}

step() {
    echo "${yellow}[STEP] $1${reset}"
}

ok() {
    echo "${green}[OK] $1${reset}"
}

verify_kubectl() {
    step "Verifying kubectl install"
    export KUBECTL=$(which kubectl)

    if [ ! $? = 0 ]; then
        error "kubectl not found, cannot continue"
    fi

    # verify the namespace
    ${KUBECTL} get ns ${NAMESPACE} &> /dev/null
    if [ ! $? = 0 ]; then
        step "Creating namespace: ${NAMESPACE}"
        kubectl create ns ${NAMESPACE} 1> /dev/null

        if [ ! $? = 0 ] ; then
            error "Cannot create namespace ${NAMESPACE}!"
        fi
    fi

    ok "Using namespace: ${NAMESPACE}"
}

install_yaml() {
    step "Creating ${1} in namespace ${NAMESPACE}"
    CREATION=$(${KUBECTL} --namespace ${NAMESPACE} create -f ${1} 2>&1)

    if [[ ${CREATION} == *"already exists"* ]] ; then
        error "Cannot apply ${1}, already present in ${NAMESPACE}"
    fi

    ok "$1 created successfully"
}

expose() {
    step "Exposing port $3/$2($4) for deployment $1 with type $5"
    EXPOSE_SVC=$(${KUBECTL} expose deployment $1 --protocol=$2 --port=$3 --name=$4 --type="$5" --namespace=${NAMESPACE} 2>&1)

    if [ ! $? = 0 ]; then
        error "Failed to expose port $3/$2 ($4). Deployment: $1"
    fi
}

run() {
    step "Running $1 ($2)"
    RUN_CMD=$(${KUBECTL} run $1 --image=$2 --env=$3 --namespace=${NAMESPACE} 2>&1)

    if [ ! $? = 0 ]; then
        error "Failed to run $1. Image: $2"
    fi

    ok "$1 is running"
}

install() {
    install_yaml ${ETCD_YAML}
    install_yaml ${VGA_YAML}

    # run and expose elasticsearch and kibana
    run elasticsearch ${ELASTICSEARCH_IMAGE}
    run kibana ${KIBANA_IMAGE} "ELASTICSEARCH_URL=http://elasticsearch:9200"
    expose "elasticsearch" "TCP" 9200 "elasticsearch" "LoadBalancer"
    expose "kibana" "TCP" 5601 "kibana" "LoadBalancer"
}

# run the pre install
verify_kubectl

# run the installation on kubernetes
install

ok "Finished setting up development environment for VAMP with Kubernetes."
