#!/bin/bash

NAMESPACE=$1

# assign namespace default if not given
: ${NAMESPACE:=default}

: "${ETCD_YAML:=https://raw.githubusercontent.com/magneticio/vamp-docker/master/vamp-kubernetes/etcd.yml}"
: "${VGA_YAML:=https://raw.githubusercontent.com/magneticio/vamp.io/master/static/res/vga.yml}"

error() {
    echo "[ERROR] $1"
    echo
    exit 1
}

ok() {
    echo "[OK] $1"
}

step() {
    echo "[STEP] $1"
}

verify_kubectl() {
    step "Verifying kubectl install"
    export KUBECTL=$(which kubectl)

    if [ ! $? = 0 ]; then
        error "Kubectl not found, cannot continue"
    fi

    ok "Using namespace: ${NAMESPACE}"

    # verify the namespace
    ${KUBECTL} get ns ${NAMESPACE} &> /dev/null
    if [ ! $? = 0 ]; then
        error "Namespace ${NAMESPACE} was not found!"
    fi
}

delete() {
    step "Running delete command: $1"
    DELETE_CMD=$(${KUBECTL} --namespace ${NAMESPACE} delete $1)

    if [ ! $? = 0 ]; then
        error "Delete command ${1} has failed, skipping"
    fi
}

verify_kubectl

step "Uninstalling vamp from namespace ${NAMESPACE}"

delete "-f ${ETCD_YAML}"
delete "-f ${VGA_YAML}"

delete "pods,services,deployments -l run=vamp"
delete "pods,services,deployments -l run=elastic"
# delete "deployments -l run=vamp"
delete "services -l vamp=deamon"
