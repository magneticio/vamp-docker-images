#! /usr/bin/env bash

# Create and delete DC/OS CE stacks in AWS

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

: "${SSH_KEY:=vamp-shared}"
: "${STACK_NAME:=dcos-katana}"
: "${TEMPLATE:=${dir}/single-master.cloudformation.json}"

# Helper functions
export TERM=xterm # XXX: To get around 'tput: No value for $TERM and no -T specified'
info() { echo "$(date +%T): $(tput setaf 2)INFO:$(tput sgr0) $@"; }
warn() { echo "$(date +%T): $(tput setaf 3)WARN:$(tput sgr0) $@"; }
erro() { echo "$(date +%T): $(tput setaf 1)ERRO:$(tput sgr0) $@" >&2; }
errexit() { erro "$@"; erro "Exiting!"; exit 1; }

pushd () { command pushd "$@" > /dev/null; }
popd () { command popd "$@" > /dev/null; }


# Do we have a readable template file?
if [[ ! -r "$TEMPLATE" ]] ; then
  errexit "${TEMPLATE}: No such file"
fi

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
export TEMPLATE
export SSH_KEY
export STACK_NAME

get_dcos_endpoint() {
  aws cloudformation describe-stacks \
    --region $AWS_REGION \
    --stack-name $STACK_NAME \
    --output text \
  | grep -E '\sDnsAddress\s' \
  | awk '{ print $5 }'
}

create() {
  info "Creating stack: $STACK_NAME"

  aws cloudformation describe-stacks \
    --region $AWS_REGION \
    --stack-name $STACK_NAME \
    --output text > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    aws cloudformation create-stack \
      --region "$AWS_REGION" \
      --stack-name "$STACK_NAME" \
      --template-body "file://${TEMPLATE}" \
      --parameters \
        "ParameterKey=KeyName,ParameterValue=${SSH_KEY}" \
        "ParameterKey=OAuthEnabled,ParameterValue=false" \
      --tags \
        "Key=Name,Value=${STACK_NAME}" \
      --capabilities CAPABILITY_IAM \
      --on-failure DELETE \
    || errexit "Failed to create stack: $STACK_NAME"

    aws cloudformation wait \
      stack-create-complete \
      --stack-name=$STACK_NAME \
      --region=$AWS_REGION \
      || errexit "Failed to create stack: $STACK_NAME"
  else
    warn "Stack already exists."
  fi

  echo "

*****************************************************************************

DCOS endpoint:
http://$(get_dcos_endpoint)

*****************************************************************************
"
}

delete() {
  info "Deleting stack: $STACK_NAME"

  aws cloudformation delete-stack \
    --region "$AWS_REGION" \
    --stack-name "$STACK_NAME" \
  || errexit "Failed to delete stack: $STACK_NAME"

  aws cloudformation wait \
    stack-delete-complete \
    --stack-name=$STACK_NAME \
    --region=$AWS_REGION \
  || errexit "Failed to delete stack: $STACK_NAME"
}


case "$1" in
  create)
    create
    ;;
  delete)
    delete
    ;;
  *)
    echo "dcos-aws.sh - Setup DC/OS on AWS"
    echo "Usage: dcos-aws.sh <create|delete>"
    exit 1
    ;;
esac
