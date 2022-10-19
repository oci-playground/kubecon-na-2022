GGCR_GIT_URL ?= https://github.com/jdolitsky/go-containerregistry
GGCR_GIT_BRANCH ?= attach

DISTRIBUTION_GIT_URL ?= https://github.com/oci-playground/distribution
DISTRIBUTION_GIT_BRANCH ?= main

.PHONY: crane
crane:
	mkdir -p clones bin
	[ -d clones/ggcr ] || git clone $(GGCR_GIT_URL) -b $(GGCR_GIT_BRANCH) clones/ggcr
	cd clones/ggcr/ && go build -o ../../bin/crane ./cmd/crane/

.PHONY: build
build:
	mkdir -p clones bin config
	[ -d clones/distribution ] || git clone $(DISTRIBUTION_GIT_URL) -b $(DISTRIBUTION_GIT_BRANCH) clones/distribution
	cd clones/distribution/ && make && mv bin/registry ../../bin/registry
	cp clones/distribution/cmd/registry/config-example-with-extensions.yml config/distribution.yml

.PHONY: serve
serve:
	bin/registry serve config/distribution.yml

.PHONY: reset
reset:
	rm -rf /tmp/registry-root-dir

.PHONY: e2e
e2e:
	scripts/e2e.sh
