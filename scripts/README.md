# Demo Script 

```bash
docker pull hello-world:latest
docker tag hello-world:latest localhost:5000/hello:latest 
docker push localhost:5000/hello:latest
```


```bash
make serve # change to use docker run 
oras copy ghcr.io/oci-playground/hello:latest localhost:5000/hello:latest

oras attach localhost:5000/hello:latest ./cat.jpg

oras manifest fetch localhost:5000/hello:latest | jq
oras manifest fetch localhost:5000/hello:latest --descriptor | jq 

## Get the referrers
curl http://localhost:5000/v2/hello/referrers/

```

## Fallback without OCI Artifact support

```bash
docker run --rm -it -p 127.0.0.1:5000:5000 docker.io/library/registry:latest 

# no tags 
oras repo tags localhost:5000

docker push localhost:5000/hello-world:latest 

regctl artifact list localhost:5000/hello-world:latest

## Show the index with manifests 
oras manifest fetch localhost:5000/hello-world:sha256-

```