#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo Make an existing tag latest.
    echo latest.sh nomad_version
    exit 1
fi

NOMAD_VERSION=$1

buildah manifest create "cannable/nomad:latest"

buildah manifest add "cannable/nomad:latest" "docker.io/cannable/nomad:amd64-${NOMAD_VERSION}"
buildah manifest add "cannable/nomad:latest" "docker.io/cannable/nomad:arm64-${NOMAD_VERSION}"

buildah manifest push -f v2s2 "cannable/nomad:latest" "docker://cannable/nomad:latest"

buildah manifest rm "cannable/nomad:latest"
