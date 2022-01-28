export DOCKER_BUILDKIT=0
TAG=ghcr.io/ryanhir/toolchain-builder

.PHONY: all
all:
	docker build \
		-t ${TAG}:bionic \
		--platform linux/amd64 \
		.
	docker push ${TAG}:bionic
