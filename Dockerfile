# This is the Dockerfile for ghcr.io/oci-playground/hello-world
#
# To build:
#
#   mkdir -p outputs
#   docker buildx build  --output=type=oci,dest=./outputs/hello_world.tar -f Dockerfile .
#   ... (TODO)
#
FROM docker.io/library/hello-world:latest
