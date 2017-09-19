#! /usr/bin/env bash

# Directory to download sources to
src_dir="../../target"

# Store script output in a log file
log_dir="../../target/log"

# set -o xtrace
set -o errexit
set -o errtrace

: "${STACK_NAME:=dcos-katana}"


VAMP_GIT_ROOT=${VAMP_GIT_ROOT:-"https://github.com/magneticio"}
VAMP_GIT_BRANCH=${VAMP_GIT_BRANCH:-"master"}


# Helper functions
export TERM=xterm # XXX: To get around 'tput: No value for $TERM and no -T specified'
info() { echo "$(date +%T): $(tput setaf 2)INFO:$(tput sgr0) $@"; }
warn() { echo "$(date +%T): $(tput setaf 3)WARN:$(tput sgr0) $@"; }
erro() { echo "$(date +%T): $(tput setaf 1)ERRO:$(tput sgr0) $@" >&2; }
errexit() { error_trap "${BASH_LINENO[0]}" "$@" 1; }
error_trap() {
  local lineno="$1"
  local message="$2"
  local code="${3:-1}"
  [[ -n "$message" ]] \
    && erro "Error on line: ${lineno}: ${message}: exiting with status ${code}" \
    || erro "Error on line: ${lineno}: exiting with status ${code}"

  exit "${code}"
}
trap 'error_trap ${LINENO}' ERR

pushd () { command pushd "$@" > /dev/null; }
popd () { command popd "$@" > /dev/null; }


script_log() {
  # Write script output to file
  local task logfile
  [[ -n $1 ]] && task=".$1" || task=""

  [[ -d $log_dir ]] || mkdir -p "$log_dir"

  logfile="${log_dir}/vamp-ui-rspec${task}.$(date +%Y%m%d_%H%M%S).log"
  > "$logfile"

  exec >  >(tee -a $logfile)     # STDOUT
  exec 2> >(tee -a $logfile >&2) # STDERR

  export LOGFILE="$logfile"
}

script_lock() {
  # Lock script depending on task on file descriptor 200 to avoid multiple
  # invocations on the same tasks, print a warning when lock is in place
  # but don't exit, as we don't want to fail all jobs if task "all" is executed
  local task lockfile
  [[ -n $1 ]] && task=".$1" || task=""
  lockfile="/tmp/vamp-runner${task}.lock"

  exec 200> "$lockfile"

  flock -n 200 \
    && return 0 \
    || { warn "Lock in place: $lockfile"; return 1; }
}

init_project() {
  # Download a git repository or update it to latest master, then add the
  # repository directory on top of the directory stack to continue work there
  local repo_url repo_dir
  [[ -n $1 ]] \
    && repo_url="$1" \
    || return 1

  [[ -n $2 ]] \
    && repo_dir="$2" \
    || repo_dir="$( basename $repo_url | sed 's/\.git$//' )"

  branch="master"

  check_url=$(curl -s -L -I ${repo_url} | grep HTTP | tail -n 1 | awk '{ print $2 }')

  if [ ${check_url} = "200" ]; then
    branch=$(git ls-remote ${repo_url} | awk '{ print $2 }' | grep -E "refs/heads/${VAMP_GIT_BRANCH}$" | sed -e "s/refs\/heads\///")
    branch=${branch:-"master"}
  else
    repo_url="https://github.com/magneticio/$(basename $repo_url)"
  fi

  info "Project '$repo_url' - ${branch} at '${src_dir}/${repo_dir}'"

  mkdir -p "$src_dir"
  pushd "$src_dir"

  if [[ -d ${repo_dir} ]] ; then
    echo "${green}updating existing repository${reset}"

    pushd "$repo_dir"

    git reset --hard
    git checkout ${branch}
    git pull
  else
    git clone -b ${branch} --depth=200 "$repo_url" "$repo_dir"
    pushd "$repo_dir"
  fi
}

build_rspec() {
  script_lock vamp-ui-rspec.build || return
  script_log vamp-ui-rspec.build

  init_project ${VAMP_GIT_ROOT}/vamp-ui-rspec.git

  info "Running vamp-ui-rspec"

  export TERM="xterm"
  make image || errexit "Failed building vamp-ui-rspec"
}

run_rspec() {
  script_lock vamp-ui-rspec.run || return
  script_log vamp-ui-rspec.run

  pushd ${src_dir}/vamp-ui-rspec

  info "Running vamp-ui-rspec"

  if [[ -n "$1" ]] ; then
    endpoint="$1"
  else
    endpoint="http://172.17.0.1:18080/service/vamp/"
  fi

  export VAMP_URL="${endpoint}"
  export TERM="xterm"
  make test || errexit "Failed building vamp-ui-rspec"
}

case "$1" in
  build)
    build_rspec
    ;;
  run)
    [[ -n $2 ]] \
      && run_rspec "$2" \
      || run_rspec
    ;;
  *)
    echo "Usage: vamp-ui-rspec.sh <build|run> [Vamp URL]"
    exit 1
    ;;
esac
