#!/usr/bin/env bash

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

function parse_command_line() {
    flag_help=0
    flag_katana=0

    for key in "$@"
    do
    case ${key} in
        -h|--help)
        flag_help=1
        ;;
        -k|--katana)
        flag_katana=1
        ;;
        -n=*|--namespace=*)
        NAMESPACE="${key#*=}"
        shift
        ;;
        *)
        ;;
    esac
    done
}

function print_help() {
    echo "${green}Usage of $0:${reset}"
    echo "${yellow}  -h  |--help        ${green}Help.${reset}"
    echo "${yellow}  -k  |--katana      ${green}Vamp katana.${reset}"
    echo "${yellow}  -n=*|--namespace=* ${green}Kubernates namespace${reset}"
}

error() {
    echo "${red}[ERROR] $1${reset}"
    echo
    if [ ! "$2" = "no-exit" ]; then
      exit 1
    fi
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
        error "Delete command ${1} has failed, skipping" "no-exit"
    fi
}

echo "${green}
╦  ╦╔═╗╔╦╗╔═╗  ╦╔═╦ ╦╔╗ ╔═╗╦═╗╔╗╔╔═╗╔╦╗╔═╗╔═╗  ╔═╗ ╦ ╦╦╔═╗╦╔═  ╔═╗╔╦╗╔═╗╦═╗╔╦╗
╚╗╔╝╠═╣║║║╠═╝  ╠╩╗║ ║╠╩╗║╣ ╠╦╝║║║║╣  ║ ║╣ ╚═╗  ║═╬╗║ ║║║  ╠╩╗  ╚═╗ ║ ╠═╣╠╦╝ ║
 ╚╝ ╩ ╩╩ ╩╩    ╩ ╩╚═╝╚═╝╚═╝╩╚═╝╚╝╚═╝ ╩ ╚═╝╚═╝  ╚═╝╚╚═╝╩╚═╝╩ ╩  ╚═╝ ╩ ╩ ╩╩╚═ ╩
${reset}"

parse_command_line $@

if [ ${flag_help} -eq 1 ]; then
    print_help
    echo
fi

if [ ${flag_katana} -eq 1 ]; then
  echo "${green}katana    : ${yellow}yes${reset}"
  : "${VGA_YAML:=https://raw.githubusercontent.com/magneticio/vamp-docker/master/vamp-kubernetes/vga.yml}"
  : "${ETCD_YAML:=https://raw.githubusercontent.com/magneticio/vamp-docker/master/vamp-kubernetes/etcd.yml}"
else
  echo "${green}katana    : ${yellow}no, otherwise use ${green}-k${yellow} or ${green}--katana${reset}"
  : "${ETCD_YAML:=https://raw.githubusercontent.com/magneticio/vamp-docker/master/vamp-kubernetes/etcd.yml}"
  : "${VGA_YAML:=https://raw.githubusercontent.com/magneticio/vamp.io/master/static/res/vga.yml}"
fi

if [ -z "${NAMESPACE}" ]; then
  NAMESPACE="default"
fi

echo "${green}namespace : ${yellow}$NAMESPACE${reset}"
echo "${green}vga file  : ${yellow}$VGA_YAML${reset}"
echo "${green}etcd file : ${yellow}$ETCD_YAML${reset}"
echo

verify_kubectl

step "Uninstalling vamp from namespace ${NAMESPACE}"

delete "-f ${ETCD_YAML}"
delete "-f ${VGA_YAML}"

delete "deployments,services,pods -l run=vamp"
delete "deployments,services,pods -l run=elastic"
delete "deployments,services,pods -l vamp=daemon"
delete "deployments,services,pods -l vamp=gateway"
delete "deployments,services,pods -l vamp=workflow"
delete "deployments,services,pods -l vamp=daemon-set"
delete "deployments,services,pods -l vamp=deployment-service"
