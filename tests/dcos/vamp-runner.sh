#! /usr/bin/env bash

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Directory to download sources to
src_dir="${root}/../../target"

# Store script output in a log file
log_dir="${root}/../../target/log"

# set -o xtrace
set -o errexit
set -o errtrace

: "${STACK_NAME:=dcos-katana}"


VAMP_GIT_ROOT=${VAMP_GIT_ROOT:-"git@github.com:magneticio"}
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

  logfile="${log_dir}/vamp-runner${task}.$(date +%Y%m%d_%H%M%S).log"
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

  local sha ref
  while read sha ref; do
    if [ "${ref}" = "refs/heads/${VAMP_GIT_BRANCH}" ]; then
      branch=${VAMP_GIT_BRANCH}
      break
    fi
    if [ "${sha}" = "fail" ]; then
      repo_url="git@github.com:magneticio/$(basename $repo_url)"
      break
    fi
  done < <(git ls-remote ${repo_url} || echo fail)

  info "Project '$repo_url' - ${branch} at '${src_dir}/${repo_dir}'"

  mkdir -p "$src_dir"
  pushd "$src_dir"

  if [[ -d ${repo_dir} ]] ; then
    echo "${green}updating existing repository${reset}"

    pushd "$repo_dir"

    git reset --hard
    git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    git fetch --depth=200 --prune
    git checkout ${branch}
    git reset --hard origin/${branch}
  else
    git clone -b ${branch} --depth=200 "$repo_url" "$repo_dir"
    pushd "$repo_dir"
  fi

  if [ -n "${VAMP_CHANGE_URL}" -a -z "${VAMP_CHANGE_URL/*\/${repo_dir}\/pull\/*/}" ]; then
    git fetch --update-head-ok origin pull/${VAMP_CHANGE_URL/*\/${repo_dir}\/pull\//}/head:${branch} || \
    git fetch --update-head-ok origin pull/${VAMP_CHANGE_URL/*\/${repo_dir}\/pull\//}/merge:${branch}
    git reset --hard
  fi
}

vr_build() {
  script_lock vamp-runner.build || return
  script_log vamp-runner.build

  init_project ${VAMP_GIT_ROOT}/vamp-runner.git

  info "Building vamp-runner"

  export TERM="xterm"
  make || errexit "Failed building vamp-runner"
}

vr_run() {
  script_lock vamp-runner.run || return
  script_log vamp-runner.run

  local vamp_url vamp_api regex vr_files_dir vr_local_dir

  if [[ -n "$1" ]] ; then
    vamp_url="$1"
  else
    info "Attempting to find Vamp installation in Azure..."
    vamp_url="http://127.0.0.1:18080/service/vamp"
  fi

  # FIXME: Make sure the URL includes schema and port number
  regex='https?://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]:[0-9]{1,5}'
  [[ $vamp_url =~ $regex ]] \
    || errexit "Malformed URL, see: https://github.com/magneticio/vamp-runner/issues/84"

  vamp_api="${vamp_url}/api/v1"

  info "URL: $vamp_url"
  info "API: $vamp_api"

  vr_files_dir="${src_dir}/vamp-runner/target/docker"
  vr_local_dir="${src_dir}/headless-vamp-runner"

  [[ -d $vr_files_dir ]] \
    || errexit "Can't find vamp-runner compiled files, please run build!"

  mkdir -p "$vr_local_dir"
  pushd "$vr_local_dir"

  cp \
    "${vr_files_dir}/vamp-runner.jar" \
    "${vr_files_dir}/application.conf" \
    "${vr_files_dir}/logback.xml" \
    "${vr_files_dir}/recipes.tar.bz2" \
      "$vr_local_dir"

  sed -i "s#/usr/local/vamp-runner#${vr_local_dir}#g" "${vr_local_dir}/application.conf"
  tar -xjf "${vr_local_dir}/recipes.tar.bz2"

  info "Writing Vamp runner headless script: ${vr_local_dir}/run-headless.sh"

  cat << EOF > "${vr_local_dir}/run-headless.sh"
#! /usr/bin/env bash
set -x
java \
  -Dvamp.runner.api.url="$vamp_api" \
  -Dlogback.configurationFile=logback.xml \
  -Dconfig.file=application.conf \
  -cp vamp-runner.jar \
  io.vamp.runner.VampConsoleRunner \
    --list \
    --run 'Auto Scaling' \
    --run 'Canary Release' \
  | tee vamp-runner-headless.log

grep -i erro vamp-runner-headless.log && exit 1

exit 0
EOF

  chmod 0775 "${vr_local_dir}/run-headless.sh"

  "${vr_local_dir}/run-headless.sh" \
    && info "Vamp runner exited successfully" \
    || (erro "Vamp runner exited with non-zero exit code" && exit 1)
}

get_aws_region() {
  # If AWS_REGION is set in the environment we'll skip the metadata API lookup
  if [[ -n "$AWS_REGION" ]] ; then
    echo "$AWS_REGION"
    return 0
  fi

  # Lookup the current running region against the AWS metadata API. This only
  # works on AWS EC2 instances however
  local aws_metadata_url region

  aws_metadata_url="http://169.254.169.254/latest/dynamic/instance-identity/document"
  region="$( curl --connect-timeout 3 --silent "$aws_metadata_url" | awk -F'"' '/region/ { print $4 }' )"

  [[ -z "$region" ]] \
    && return 1 \
    || echo "$region"
}

get_dcos_endpoint() {
  local aws_region stack_name

  aws_region=$( get_aws_region ) || return 1
  stack_name="$STACK_NAME"

  aws cloudformation describe-stacks  \
    --region "$aws_region" \
    --stack-name "$stack_name" \
    --output text \
  | awk '$1 ~ /^OUTPUTS$/ && $4 ~ /^DnsAddress$/ { print $NF }'
}

case "$1" in
  build)
    vr_build
    ;;
  run)
    [[ -n $2 ]] \
      && vr_run "$2" \
      || vr_run
    ;;
  *)
    echo "Usage: vamp-runner.sh <build|run> [Vamp URL]"
    exit 1
    ;;
esac
