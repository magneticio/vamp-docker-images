#! /usr/bin/env bash

# Get latest Cloudformation templates

URL="https://downloads.dcos.io/dcos/stable/aws.html"
TMP="$(mktemp /tmp/dcos-aws.XXXXXX)"

# Helper functions
export TERM=xterm # XXX: To get around 'tput: No value for $TERM and no -T specified'
info() { echo "$(date +%T): $(tput setaf 2)INFO:$(tput sgr0) $@"; }
warn() { echo "$(date +%T): $(tput setaf 3)WARN:$(tput sgr0) $@"; }
erro() { echo "$(date +%T): $(tput setaf 1)ERRO:$(tput sgr0) $@" >&2; }
errexit() { erro "$@"; erro "Exiting!"; exit 1; }

pushd () { command pushd "$@" > /dev/null; }
popd () { command popd "$@" > /dev/null; }

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

info "Fetching latest template links..."
lynx -dump -listonly "$URL" \
  | awk -F'=' '/cloudformation.json$/ { print $NF; }' \
  | sort -u > "$TMP"

for tmpl_url in $( < "$TMP" ) ; do
  tmpl_out="${tmpl_url##*/}"
  info "Downloading template '$tmpl_out' to '$dir'"
  curl --location --silent --output "${dir}/${tmpl_out}" "$tmpl_url"
done

rm -f "$TMP"
