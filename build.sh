#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo build.sh nomad_version
    exit 1
fi

NOMAD_VERSION=$1

podman pull --arch amd64 docker.io/library/almalinux:8
podman pull --arch amd64 docker.io/library/almalinux:8

buildah bud --arch amd64 --tag "cannable/nomad:amd64-${NOMAD_VERSION}" --build-arg "NOMAD_VERSION=${NOMAD_VERSION}" -f ./Dockerfile .
buildah bud --arch arm64 --tag "cannable/nomad:arm64-${NOMAD_VERSION}" --build-arg "NOMAD_VERSION=${NOMAD_VERSION}" -f ./Dockerfile .


buildah push -f v2s2 "cannable/nomad:amd64-${NOMAD_VERSION}" "docker://cannable/nomad:amd64-${NOMAD_VERSION}"
buildah push -f v2s2 "cannable/nomad:arm64-${NOMAD_VERSION}" "docker://cannable/nomad:arm64-${NOMAD_VERSION}"


buildah manifest create "cannable/nomad:${NOMAD_VERSION}"

buildah manifest add "cannable/nomad:${NOMAD_VERSION}" "docker.io/cannable/nomad:amd64-${NOMAD_VERSION}"
buildah manifest add "cannable/nomad:${NOMAD_VERSION}" "docker.io/cannable/nomad:arm64-${NOMAD_VERSION}"

buildah manifest push -f v2s2 "cannable/nomad:${NOMAD_VERSION}" "docker://cannable/nomad:${NOMAD_VERSION}"

buildah manifest rm "cannable/nomad:${NOMAD_VERSION}"
