#!/bin/bash

NAMESPACE=$1

# assign namespace default if not given
: ${NAMESPACE:=default}

ETCD_YAML=https://raw.githubusercontent.com/magneticio/vamp-docker/master/vamp-kubernetes/etcd.yml
VGA_YAML=https://raw.githubusercontent.com/magneticio/vamp.io/master/static/res/vga.yml
ES_IMG=magneticio/elastic:2.2
VAMP_IMG=magneticio/vamp:katana-kubernetes

error() {
    echo "[ERROR] $1"
    echo
    exit 1
}

step() {
    echo "[STEP] $1"
}

ok() {
    echo "[OK] $1"
}

verify_kubectl() {
    step "Verifying kubectl install"
    export KUBECTL=$(which kubectl)

    if [ ! $? = 0 ]; then
        error "Kubectl not found, cannot continue"
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
    RUN_CMD=$(${KUBECTL} run $1 --image=$2 --namespace=${NAMESPACE} 2>&1)

    if [ ! $? = 0 ]; then
        error "Failed to run $1. Image: $2"
    fi

    ok "$1 is running"
}

install() {
    install_yaml ${ETCD_YAML}
    install_yaml ${VGA_YAML}

    # run and expose elasticsearch
    run elastic ${ES_IMG}
    expose "elastic" "TCP" 9200 "elasticsearch" "ClusterIP"
    expose "elastic" "UDP" 10001 "logstash" "ClusterIP"
    expose "elastic" "TCP" 5601 "kibana" "ClusterIP"

    # run and expose vamp
    run "vamp" ${VAMP_IMG}
    expose "vamp" "TCP" 8080 "vamp" "LoadBalancer"

}
step "Vamp Kubernetes Quickstart running"
echo

# run the pre install
verify_kubectl

# run the installation on kubernetes
install

step "Polling kubernetes for external ip of Vamp (this might take a while)..."
# poll for the external ip address, give up after 10 attempts
external_ip=""
for (( i=0; i<=9; i++ )) ; do
    [[ -n "$external_ip" ]] && break
    sleep 20

    external_ip=$(${KUBECTL} --namespace ${NAMESPACE} get svc vamp --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")

    if [ ! $? = 0 ]; then
        error "Failed to retrieve external ip address for vamp"
    fi

    step "Still polling for Vamp ip..."
done

[[ -n "$external_ip" ]] \
    && ok "Quickstart finished, Vamp is running on http://$external_ip:8080" \
    || error "Couldn't get IP address of Vamp, please check logs for more info"

