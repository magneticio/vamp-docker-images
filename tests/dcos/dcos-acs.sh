#!/bin/bash -e

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Helper functions
export TERM=xterm # XXX: To get around 'tput: No value for $TERM and no -T specified'
info() { echo "$(date +%T): $(tput setaf 2)INFO:$(tput sgr0) $@"; }
warn() { echo "$(date +%T): $(tput setaf 3)WARN:$(tput sgr0) $@"; }
erro() { echo "$(date +%T): $(tput setaf 1)ERRO:$(tput sgr0) $@" >&2; }
errexit() { erro "$@"; erro "Exiting!"; exit 1; }
wait_for_service() {
  TASK_NAME="$1"
  REQUIRED_TASKS=$2
  CURRENT_TASKS=0
  COUNTER=0
  while [[ $CURRENT_TASKS -ne $REQUIRED_TASKS && $COUNTER -lt 600 ]]; do
    CURRENT_TASKS=`dcos marathon task list | grep ${TASK_NAME} | grep -Ev 'None' | awk '{ print $2 }' | grep -i true | wc -l`
    COUNTER=$[COUNTER+1]
    sleep 1
  done
}

acs_create() {
  cd terraform
  export TF_VAR_ssh_key="$(cat ~/.ssh/id_rsa.pub)"
  terraform init
  terraform apply
  terraform refresh
  fqdn=$(terraform output dcos-master-url | grep fqdn | awk -F ' = ' '{ print $2 }')
  cd -
  ssh-keygen -R [${fqdn}]:2200 || true
  ssh -oStrictHostKeyChecking=no -fNL 0.0.0.0:18080:localhost:80 -p 2200 dcos@${fqdn}
  dcos config set core.dcos_url http://127.0.0.1:18080
}

acs_delete() {
  cd terraform
  terraform destroy -force
  cd -
}

vamp_install() {
  info "Installing MySQL"

  dcos marathon app add "${dir}/marathon/mysql.json" \
    || errexit "Failed to install MySQL"

  wait_for_service "mysql" 1

  info "Installing Elasticsearch"

  dcos marathon app add "${dir}/marathon/elasticsearch.json" \
    || errexit "Failed to install Elasticsearch"

  wait_for_service "elasticsearch" 1

  info "Installing Vamp"

  dcos marathon app add "${dir}/marathon/vamp.json" \
    || errexit "Failed to install Vamp"

  wait_for_service "vamp" 10
}

vamp_uninstall() {
  info "Uninstalling Vamp"
  dcos marathon group remove --force vamp \
    || errexit "Failed to remove Vamp"

  info "Uninstalling Elasticsearch"
  dcos marathon app remove --force elasticsearch \
    || errexit "Failed to remove Elasticsearch"

  info "Uninstalling MySQL"
  dcos marathon app remove --force mysql \
    || errexit "Failed to remove MySQL"
}

vamp_clean() {
  info "Uninstalling Vamp"
  dcos marathon group remove --force vamp \
    || warn "Failed to remove Vamp"

  info "Uninstalling Elasticsearch"
  dcos marathon app remove --force elasticsearch \
    || warn "Failed to remove Elasticsearch"

  info "Uninstalling MySQL"
  dcos marathon app remove --force mysql \
    || warn "Failed to remove MySQL"

  # wait for services to be removed
  REQUIRED_TASKS=0
  CURRENT_TASKS=-1
  while [ $CURRENT_TASKS -ne $REQUIRED_TASKS ]; do
    CURRENT_TASKS=`dcos marathon task list | wc -l`
    sleep 1
  done
}

case "$1" in
  create)
    acs_create
    ;;
  delete)
    acs_delete
    ;;
  install)
    vamp_install
    ;;
  uninstall)
    vamp_uninstall
    ;;
  clean)
    vamp_clean
    ;;
  *)
    echo "$(echo $0) - Setup Vamp on ACS with DC/OS"
    echo "Usage: $(echo $0) <create|destroy|install|uninstall|clean>"
    exit 1
    ;;
esac
