# Demo Instructions 

Copy the OCI image to your local registry 

```bash
oras cp ghcr.io/oci-playground/hello-world:latest localhost:5000/hello-world:latest 
```


```bash
make serve # change to use docker run 
oras copy ghcr.io/oci-playground/hello-world:latest localhost:5000/hello-world:latest
oras manifest fetch localhost:5000/hello-world:latest
oras manifest fetch localhost:4999/hello-world:latest --descriptor | jq 

oras attach localhost:5000/hello-world:latest --artifact-type example/foo ./cat.jpg:image/jpg

oras attach localhost:5000/hello-world:latest --artifact-type example/bar ./hello.txt:text/plain

## Get the referrers
curl http://localhost:5000/v2/hello-world/referrers/sha256:34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c

```

## Fallback without OCI Artifact support

```bash
docker run --rm -it -p 127.0.0.1:5000:5000 docker.io/library/registry:latest 

# no tags 
oras repo tags localhost:5000/hello-world

regctl artifact push -f ./cat.jpg --subject localhost:5000/hello-world:latest

oras repo tags localhost:5000/hello-world
regctl artifact push -f ./hello.txt --subject localhost:5000/hello-world:latest


## Show the index with manifests 
oras manifest fetch localhost:5000/hello-world:sha256-34b7abc75bb574d97e93d23cdd13ed92b39ee6661a221a8fdcfa57cff8e80f4c
```