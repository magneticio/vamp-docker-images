#! /usr/bin/env bash

# Install Vamp on DC/OS

# Helper functions
export TERM=xterm # XXX: To get around 'tput: No value for $TERM and no -T specified'
info() { echo "$(date +%T): $(tput setaf 2)INFO:$(tput sgr0) $@"; }
warn() { echo "$(date +%T): $(tput setaf 3)WARN:$(tput sgr0) $@"; }
erro() { echo "$(date +%T): $(tput setaf 1)ERRO:$(tput sgr0) $@" >&2; }
errexit() { erro "$@"; erro "Exiting!"; exit 1; }

pushd () { command pushd "$@" > /dev/null; }
popd () { command popd "$@" > /dev/null; }

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


vamp_install() {
  info "Installing MariaDB"

  dcos marathon app add "${dir}/marathon/mariadb.json" \
    || errexit "Failed to install MariaDB"

  # wait for MariaDB to be deployed
  REQUIRED_TASKS=1
  CURRENT_TASKS=0
  while [ $CURRENT_TASKS -ne $REQUIRED_TASKS ]; do
    CURRENT_TASKS=`dcos marathon task list | grep mariadb | awk '{ print $2 }' | grep -i true | wc -l`
    sleep 1
  done

  info "Installing Elasticsearch"

  dcos marathon app add "${dir}/marathon/elasticsearch.json" \
    || errexit "Failed to install Elasticsearch"

  # wait for Elasticsearch to be deployed
  REQUIRED_TASKS=1
  CURRENT_TASKS=0
  while [ $CURRENT_TASKS -ne $REQUIRED_TASKS ]; do
    CURRENT_TASKS=`dcos marathon task list | grep elasticsearch | awk '{ print $2 }' | grep -i true | wc -l`
    sleep 1
  done

  info "Installing Vamp"

  dcos marathon app add "${dir}/marathon/vamp.json" \
    || errexit "Failed to install Vamp"

  # wait for services to be deployed
  REQUIRED_TASKS=12
  CURRENT_TASKS=0
  while [ $CURRENT_TASKS -ne $REQUIRED_TASKS ]; do
    CURRENT_TASKS=`dcos marathon task list | grep vamp | awk '{ print $2 }' | grep -i true | wc -l`
    sleep 1
  done
}

vamp_uninstall() {
  info "Uninstalling Vamp"
  dcos marathon group remove --force vamp \
    || errexit "Failed to remove Vamp"

  info "Uninstalling Elasticsearch"
  dcos marathon app remove --force elasticsearch \
    || errexit "Failed to remove Elasticsearch"

  info "Uninstalling MariaDB"
  dcos marathon app remove --force mariadb \
    || errexit "Failed to remove MariaDB"
}

vamp_clean() {
  info "Uninstalling Vamp"
  dcos marathon group remove --force vamp \
    || warn "Failed to remove Vamp"

  info "Uninstalling Elasticsearch"
  dcos marathon app remove --force elasticsearch \
    || warn "Failed to remove Elasticsearch"

  info "Uninstalling MariaDB"
  dcos marathon app remove --force mariadb \
    || warn "Failed to remove MariaDB"

  # wait for services to be removed
  REQUIRED_TASKS=0
  CURRENT_TASKS=-1
  while [ $CURRENT_TASKS -ne $REQUIRED_TASKS ]; do
    CURRENT_TASKS=`dcos marathon task list | wc -l`
    sleep 1
  done
}

case "$1" in
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
    echo "dcos-vamp.sh - Setup Vamp on DC/OS"
    echo "Usage: dcos-vamp.sh <install|uninstall|clean>"
    exit 1
    ;;
esac
