export VAMP_GIT_ROOT=${VAMP_GIT_ROOT:-"git@github.com:magneticio"}

if [ -n "${CHANGE_TARGET:=}" ]; then
  export VAMP_CHANGE_TARGET=${CHANGE_TARGET}
  export VAMP_CHANGE_URL=${CHANGE_URL}
  export VAMP_TAG_PREFIX="pr-$(echo ${CHANGE_URL} | sed -e 's,.*/vamp-docker-images/pull/,,g')-"
elif [ -n "${BUILD_NUMBER:=}" ]; then
  export VAMP_TAG_PREFIX="build-${BUILD_NUMBER}-"
fi

if [ -n "${VAMP_CHANGE_TARGET:=}" ]; then
  export VAMP_GIT_BRANCH=${VAMP_CHANGE_TARGET}
fi

export VAMP_GIT_BRANCH=${VAMP_GIT_BRANCH:=${BRANCH_NAME:-master}}

# TODO: remove this
if [ "${VAMP_GIT_BRANCH}" = "master" ]; then
  unset VAMP_TAG_PREFIX
fi

tag=$(echo ${VAMP_GIT_BRANCH} | sed 's,/,_,g')
if [ "${VAMP_GIT_BRANCH}" = "master" ]; then
  tag=katana
fi
tag="${VAMP_TAG_PREFIX:=}${tag}"

export PACKER="packer-${VAMP_TAG_PREFIX}$(git describe --all | sed 's,/,_,g')"
