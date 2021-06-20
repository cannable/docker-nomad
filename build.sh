#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo build.sh nomad_version
    exit 1
fi

version=$1
arches=(amd64 arm64)

for arch in ${arches[@]}; do
    buildah bud --arch "$arch" --tag "cannable/nomad:${arch}-${version}" --build-arg "NOMAD_VERSION=${version}" -f ./Dockerfile .
    buildah push -f v2s2 "cannable/nomad:${arch}-${version}" "docker://cannable/nomad:${arch}-${version}"
done

buildah manifest create "cannable/nomad:${version}"

for arch in ${arches[@]}; do
    buildah manifest add "cannable/nomad:${version}" "docker.io/cannable/nomad:${arch}-${version}"
done

buildah manifest push -f v2s2 "cannable/nomad:${version}" "docker://cannable/nomad:${version}"

buildah manifest rm "cannable/nomad:${version}"
