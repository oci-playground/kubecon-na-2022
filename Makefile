GGCR_GIT_URL ?= https://github.com/jdolitsky/go-containerregistry
GGCR_GIT_BRANCH ?= attach

DISTRIBUTION_GIT_URL ?= https://github.com/oci-playground/distribution
DISTRIBUTION_GIT_BRANCH ?= main

ORAS_GIT_URL ?= https://github.com/oci-playground/oras
ORAS_GIT_BRANCH ?= main

REGCTL_GIT_URL ?= https://github.com/regclient/regclient
REGCTL_GIT_BRANCH ?= main

.PHONY: help
help: ## Generates help for all targets
	@grep -E '^[^#[:space:]].*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

.PHONY: crane
crane:
	mkdir -p clones bin
	[ -d clones/ggcr ] || git clone $(GGCR_GIT_URLORAS_GIT_URL) -b $(GGCR_GIT_BRANCH) clones/ggcr
	cd clones/ggcr/ && go build -o ../../bin/crane ./cmd/crane/

.PHONY: oras
oras:
	mkdir -p clones bin
	[ -d clones/oras ] || git clone $(ORAS_GIT_URL) -b $(ORAS_GIT_BRANCH) clones/oras
	cd clones/oras/ && go build -o ../../bin/oras ./cmd/oras/

.PHONY: regctl
regctl: 
	mkdir -p clones bin 
	[ -d clones/regctl ] || git clone $(REGCTL_GIT_URL) -b $(REGCTL_GIT_BRANCH) clones/regctl
	cd clones/regctl/ && go build -o ../../bin/regctl ./cmd/regctl/

.PHONY: build
build: ## Make distribution with OCI support
	mkdir -p clones bin config
	[ -d clones/distribution ] || git clone $(DISTRIBUTION_GIT_URL) -b $(DISTRIBUTION_GIT_BRANCH) clones/distribution
	cd clones/distribution/ && make && mv bin/registry ../../bin/registry
	cp clones/distribution/cmd/registry/config-example-with-extensions.yml config/distribution.yml

.PHONY: serve
serve:  ## Start distribution with OCI support
	bin/registry serve config/distribution.yml

.PHONY: serve-no-oci
serve-no-oci: ## Run the registry without OCI support 
	docker run --rm -it -p 127.0.0.1:5000:5000 docker.io/library/registry:latest 

.PHONY: reset
reset: ## Remove /tmp/registry-root-dir
	rm -rf /tmp/registry-root-dir

.PHONY: e2e
e2e: ## Run the e2e script
	scripts/e2e.sh


.PHONY: build-oci-image
build-oci-image: ## Docker build and OCI image
	mkdir -p outputs
	docker buildx build  --output=type=oci,dest=./outputs/hello_world.tar -f Dockerfile .