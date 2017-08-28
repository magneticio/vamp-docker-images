#! /usr/bin/env bash

# Install and configure the DC/OS CLI

: "${STACK_NAME:=dcos-katana}"


# Helper functions
export TERM=xterm # XXX: To get around 'tput: No value for $TERM and no -T specified'
info() { echo "$(date +%T): $(tput setaf 2)INFO:$(tput sgr0) $@"; }
warn() { echo "$(date +%T): $(tput setaf 3)WARN:$(tput sgr0) $@"; }
erro() { echo "$(date +%T): $(tput setaf 1)ERRO:$(tput sgr0) $@" >&2; }
errexit() { erro "$@"; erro "Exiting!"; exit 1; }

pushd () { command pushd "$@" > /dev/null; }
popd () { command popd "$@" > /dev/null; }

# Do we have a region specified?
if [[ -z "$AWS_REGION" ]] ; then
  warn "No region specifed!"

  info "Trying to get region from meta-data API..."
  aws_metadata_url="http://169.254.169.254/latest/dynamic/instance-identity/document"
  region="$( curl --connect-timeout 3 --silent "$aws_metadata_url" | awk -F'"' '/region/ { print $4 }' )"

  if [[ -z "$region" ]] ; then
    errexit "Unable to get region from meta-data API"
  else
    info "Got region: $region"
    AWS_REGION="$region"
  fi
fi
export AWS_REGION

get_dcos_endpoint() {
  aws cloudformation describe-stacks  \
    --region "$AWS_REGION" \
    --stack-name "$STACK_NAME" \
    --output text \
  | awk '$1 ~ /^OUTPUTS$/ && $4 ~ /^DnsAddress$/ { print $NF }'

}

install_cli() {
  info "Installing DC/OS CLI"

  [[ -d "${HOME}/bin" ]] || mkdir -p "${HOME}/bin"

  local cli_url="https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.8/dcos"
  local cli_bin="${HOME}/bin/dcos"

  [[ -e "$cli_bin" ]] && { warn "DC/OS CLI already installed, skipping!"; return 0; }

  curl "$cli_url" \
    --output "${HOME}/bin/dcos" \
    --show-error \
    --location || errexit "Unable to install DC/OS CLI"

  chmod 0755 "$cli_bin"
}

configure_cli() {
  [[ -z $1 ]] && return 1

  info "Configuring DC/OS CLI"

  local dcos_endpoint="$1"
  local dcos_dir="${HOME}/.dcos"
  local dcos_cfg="${dcos_dir}/dcos.toml"

  mkdir -p "$dcos_dir"
  chmod 0700 "$dcos_dir"

  printf -- "[core]\ndcos_url = \"%s\"\n" "$dcos_endpoint" > "$dcos_cfg"
  chmod 0600 "$dcos_cfg"
}

DCOS_ENDPOINT="http://$( get_dcos_endpoint )"

install_cli
configure_cli "$DCOS_ENDPOINT"
