# Kubecon 2022 North America 

The repo contains steps to reproduce the
demo from [this talk](https://kccncna2022.sched.com/event/182G5/its-complicated-relationships-between-objects-in-oci-registries-josh-dolitsky-chainguard-sajay-antony-microsoft) at KubeCon + CloudNative North America 2022!

## Setup

Requires Docker.

Note: the aliases below will redirect `localhost` inside the container to the container running the registry on port 5000.
The `alias` commands should be run only after you have a registry up and running.

### oras

This is a version of `oras` published from https://github.com/oci-playground/oras (commit `b5e2f9872c68dc11452bedaeda0b73328f26846f`)

```
alias oras="docker run --rm -it -v "$(pwd):/workspace" --add-host "localhost:$(docker ps | grep '5000->5000' | awk '{print $1}' | xargs docker inspect | jq -r '.[0].NetworkSettings.IPAddress')" ghcr.io/oci-playground/oras@sha256:e13dc345d2c42c270964a5de15613b7374af8f58f55bedcfb75397c8d6e88a1c"
```

### regctl

This is a version of `regctl` published from https://github.com/regclient/regclient (commit `d436d53eb7304e32bd6f2757c5624e1bc9009c9b`)

```
alias regctl="docker run --rm -it -v "$(pwd):/workspace" --add-host "localhost:$(docker ps | grep '5000->5000' | awk '{print $1}' | xargs docker inspect | jq -r '.[0].NetworkSettings.IPAddress')" -e REGCTL_CONFIG=/workspace/regctl-config.json -w /workspace ghcr.io/regclient/regctl@sha256:2bd688eeb8597fd64881f5d4fd73647a5e3249be0d7c1bf8c04df0ff02b049b2"
```

## Push using the new OCI Artifacts

```bash
# Run the registry with OCI support
docker run --rm -it -p 127.0.0.1:5000:5000 ghcr.io/oci-playground/registry@sha256:a7a7b3b904337e8b81d06769157a165ba3becb96445b4473df04264b4970c3fa

# Copy an OCI image and see its manifest (you can use a different image here if you want)
oras copy ghcr.io/oci-playground/hello-world@sha256:34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c localhost:5000/hello-world:latest
oras manifest fetch localhost:5000/hello-world:latest | jq
oras manifest fetch localhost:5000/hello-world:latest --descriptor | jq

# Attach an OCI artifact
oras attach localhost:5000/hello-world:latest --artifact-type example/foo ./cat.jpg:image/jpg --export-manifest attached.json
oras manifest fetch "localhost:5000/hello-world@sha256:$(cat attached.json | shasum -a 256 | cut -d ' ' -f 1)" | jq

## Get the referrers
curl -s http://localhost:5000/v2/hello-world/referrers/sha256:34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c | jq

# Attach the second artifact
echo "hello world" > hello.txt
oras attach localhost:5000/hello-world:latest --artifact-type example/bar ./hello.txt:text/plain

# See referrers again with multiple manifest
curl -s http://localhost:5000/v2/hello-world/referrers/sha256:34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c | jq
```

## Fallback without OCI Artifact support

```bash
# Run the registry without artifact support
docker run --rm -it -p 127.0.0.1:5000:5000 docker.io/library/registry@sha256:2e830e8b682d73a1b70cac4343a6a541a87d5271617841d87eeb67a824a5b3f2

# Copy an OCI image and see its manifest (you can use a different image here if you want)
oras copy ghcr.io/oci-playground/hello-world@sha256:34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c localhost:5000/hello-world:latest

# Push an OCI image manifest Artifact
regctl artifact push -f ./cat.jpg --artifact-type example/foo --subject localhost:5000/hello-world:latest

# View the digest-tags
oras repo tags localhost:5000/hello-world

# Show the index with manifests
oras manifest fetch localhost:5000/hello-world:sha256-34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c | jq
regctl artifact push -f ./hello.txt --subject localhost:5000/hello-world:latest

# Push the second OCI artifact
regctl artifact push -f ./hello.txt  --artifact-type example/bar --subject localhost:5000/hello-world:latest

## Show the index with manifests
oras manifest fetch localhost:5000/hello-world:sha256-34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c | jq
```
