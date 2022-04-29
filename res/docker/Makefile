export DOCKER_BUILDKIT=0
export DOCKER_SCAN_SUGGEST=false
TAG=ghcr.io/ryanhir/opensdk

.PHONY: all
all:
	docker build \
		-t ${TAG}:bionic \
		--platform linux/amd64 \
		.
	docker push ${TAG}:bionic
