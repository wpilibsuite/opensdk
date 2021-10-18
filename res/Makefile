export DOCKER_BUILDKIT=0
TAG=ghcr.io/ryanhir/toolchain-builder:latest
.PHONY: build pull push

all: build push manifest

build: build-amd64 build-i386
push: push-amd64 push-i386

manifest: push
	docker manifest create ${TAG} \
		--amend ${TAG}-i386 \
		--amend ${TAG}-amd64
	docker manifest push ${TAG}
build-%:
	docker build \
		-t ${TAG}-$(patsubst build-%,%,$@) \
		--platform linux/$(patsubst build-%,%,$@) \
		--build-arg ARCH=$(patsubst build-%,%,$@) \
		.
push-%:
	docker push \
		${TAG}-$(patsubst push-%,%,$@)

