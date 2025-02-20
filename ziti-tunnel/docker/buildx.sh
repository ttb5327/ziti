#!/usr/bin/env bash
set -euo pipefail

_usage(){
    cat >&2 <<-EOF
Usage: VARIABLES ./${BASENAME} -r REPO [OPTIONS]

Build multi-platform Docker container image on Linux.

VARIABLES
    ZITI_VERSION      e.g. "0.16.1" corresponding to Git tag "v0.16.1"

REQUIRED
    -r REPO           required container image repository e.g. netfoundry/ziti-edge-tunnel

OPTIONS
    -c                don't check out v\${ZITI_VERSION} (use Git working copy)
    -P                don't push the container image to Hub

EXAMPLES
    ZITI_VERSION=0.16.1 ./${BASENAME} -c

REFERENCE
    https://github.com/openziti/ziti-tunnel-sdk-c/blob/main/docker/BUILD.md
EOF
    [[ $# -eq 1 ]] && {
        return "$1"
    } || {
        return 0
    }
}

BASENAME=$(basename "$0") || exit $?
DIRNAME=$(dirname "$0") || exit $?

while getopts :chPr: OPT;do
    case $OPT in
        c) 	FLAGS+=$OPT     # don't checkout vZITI_VERSION
            ;;
        h) _usage; exit 0   # not an error
            ;;
        P) 	FLAGS+=$OPT     # don't push container image to Hub
            ;;
        r)  CONTAINER_REPO=$OPTARG 
            ;;
        *|\?) _usage 1      # error
            ;;
    esac
done
shift "$((OPTIND-1))"

# default to latest
: "${ZITI_VERSION:=$(git fetch --quiet --tags && git tag -l|sort -Vr|head -1|sed -E 's/^v(.*)/\1/')}"

[[ -n "${CONTAINER_REPO:-}" ]] || {
    echo "ERROR: missing -r REPO option to define container image repository name for tagging the image" >&2
    _usage; exit 1
}

if [[ ${FLAGS:-} =~ c ]]; then
    echo "WARN: not checking out Git tag v${ZITI_VERSION}"
else
    git diff --exit-code # bail if unstaged differences
    git fetch --tags
    git checkout "v${ZITI_VERSION}"
fi

docker run --rm --privileged linuxkit/binfmt:v0.8
grep -E -q enabled /proc/sys/fs/binfmt_misc/qemu-arm
docker run --rm --platform arm arm32v7/alpine  uname -a|grep -E -q 'armv7l Linux'
docker run --rm --platform arm64 arm64v8/alpine uname -a|grep -E -q 'aarch64 Linux'

docker buildx create --use --name=ziti-builder 2>/dev/null || docker buildx use --default ziti-builder

# if default then push to Hub
BUILDX_OUTPUT="--push"
if [[ ${FLAGS:-} =~ P ]]; then
    # if no push then load in image cache
    BUILDX_OUTPUT=""
fi

eval docker buildx build "$DIRNAME" \
    --platform linux/amd64,linux/arm/v7,linux/arm64 \
    --build-arg "ZITI_VERSION=${ZITI_VERSION}" \
    --tag "${CONTAINER_REPO}:${ZITI_VERSION}" \
    --tag "${CONTAINER_REPO}:latest" \
    "${BUILDX_OUTPUT:-}"

docker buildx stop ziti-builder
