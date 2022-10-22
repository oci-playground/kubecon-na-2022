# Kubecon 2022 North America 

## Push using the new OCI Artifacts
```bash
# Run the registry with OCI support
docker run --rm -it -p 127.0.0.1:5000:5000 ghcr.io/oci-playground/registry:latest

# Copy an OCI image and see its manifest
oras copy ghcr.io/oci-playground/hello-world:latest localhost:5000/hello-world:latest
oras manifest fetch localhost:5000/hello-world:latest | jq
oras manifest fetch localhost:5000/hello-world:latest --descriptor | jq 

# Attach an OCI artifact
oras attach localhost:5000/hello-world:latest --artifact-type example/foo ./cat.jpg:image/jpg
oras manifest fetch localhost:5000/hello-world@<artifact-digest>

## Get the referrers
curl http://localhost:5000/v2/hello-world/referrers/sha256:34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c

# Attach the second artifact
oras attach localhost:5000/hello-world:latest --artifact-type example/bar ./hello.txt:text/plain

# See referrers again with multiple manifest
curl http://localhost:5000/v2/hello-world/referrers/sha256:34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c
```

## Fallback without OCI Artifact support

```bash
# Run the registry without artifact support
docker run --rm -it -p 127.0.0.1:5000:5000 docker.io/library/registry:latest 

# Copy an OCI image and see its manifest
oras copy ghcr.io/oci-playground/hello-world:latest localhost:5000/hello-world:latest

# Push an OCI image manifest Artifact
regctl artifact push -f ./cat.jpg --artifact-type example/foo --subject localhost:5000/hello-world:latest

# View the digest-tags
oras repo tags localhost:5000/hello-world

# Show the index with manifests 
oras manifest fetch localhost:5000/hello-world:sha256-34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c
regctl artifact push -f ./hello.txt --subject localhost:5000/hello-world:latest

# Push the second OCI artifact 
regctl artifact push -f ./hello.txt  --artifact-type example/bar --subject localhost:5000/hello-world:latest

## Show the index with manifests 
oras manifest fetch localhost:5000/hello-world:sha256-34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c
```

## Build from source 


### Build registry

```
make build
```

### Run registry

```
make serve
```

### Reset registry contents

```
make reset
```

### Run E2E script

```
make e2e
```
