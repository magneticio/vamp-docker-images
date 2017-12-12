#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export CLEAN_BUILD=false
exec ${dir}/build.sh
