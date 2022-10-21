#!/usr/bin/env bash

# Originally from https://github.com/oci-playground/distribution/pull/15

set -ex

# set variables testing
reg=localhost:5000
repo=hello
name=${reg}/$repo
tag=latest
# oras_flags="--plain-http"
oras_flags=""

# push a regular artifact
echo hello world > hello.txt
oras push ${name}:${tag} hello.txt ${oras_flags}

# contruct an OCI artifact and attach
attach() {
    local name=$1
    local tag=$2
    local artifact_type=$3
    cat <<EOF | jq | oras manifest push ${name} - ${oras_flags}
{
  "mediaType": "application/vnd.oci.artifact.manifest.v1+json",
  "artifactType": "${artifact_type}",
  "blobs": [],
  "subject": $(oras manifest fetch ${name}:${tag} --descriptor ${oras_flags}),
  "annotations": {
    "org.opencontainers.artifact.created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  }
}
EOF
}

attach ${name} ${tag} foo
sleep 1
attach ${name} ${tag} foo
attach ${name} ${tag} bar

# call referrers API
# filters are not attempted since it is not implemented
digest=$(oras manifest fetch ${name}:${tag} --descriptor ${oras_flags} | jq -r .digest)
curl -s http://$reg/v2/$repo/referrers/$digest | jq

# let's try fallbacks
attach_fallback() {
    local name=$1
    local tag=$2
    local artifact_type=$3

    local config=$(echo -n "{}" | oras blob push --size 2 \
        ${name}@sha256:44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a \
        - --descriptor --media-type ${artifact_type} ${oras_flags})

    cat <<EOF | jq | oras manifest push ${name} - ${oras_flags}
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "config": ${config},
  "layers": [],
  "subject": $(oras manifest fetch ${name}:${tag} --descriptor ${oras_flags}),
  "annotations": {
    "org.opencontainers.artifact.created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  }
}
EOF
}

attach_fallback ${name} ${tag} foo_fallback
sleep 1
attach_fallback ${name} ${tag} foo_fallback
attach_fallback ${name} ${tag} bar_fallback

# call referrers API
curl -s http://$reg/v2/$repo/referrers/$digest | jq
