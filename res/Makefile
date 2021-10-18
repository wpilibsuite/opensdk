export DOCKER_BUILDKIT=0
TAG=ghcr.io/ryanhir/toolchain-builder:latest
.PHONY: build pull push

ARCH_LIST=amd64 i386

all: $(foreach arch,${ARCH_LIST},build-${arch} push-${arch}) manifest

manifest:
	docker manifest create ${TAG} \
		$(foreach arch,${ARCH_LIST},--amend ${TAG}-${arch})
	docker manifest push ${TAG}

build-%:
	docker build \
		-t ${TAG}-$* \
		--platform linux/$* \
		--build-arg ARCH=$* \
		.
push-%: build-%
	docker push \
		${TAG}-$*

