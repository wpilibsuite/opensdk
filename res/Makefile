export DOCKER_BUILDKIT=0
TAG=ghcr.io/ryanhir/toolchain-builder

.PHONY: all
all: manifest

# Cannot be a part of the Ubuntu Ports
ARCH_LIST=amd64 i386

manifest: manifest-bionic manifest-xenial
	/bin/true

manifest-%: $(foreach arch,${ARCH_LIST},%/build-${arch})
	docker manifest create ${TAG}:$* \
		$(foreach arch,${ARCH_LIST},--amend ${TAG}:$*-${arch})
	docker manifest push ${TAG}:$*


bionic/build-%:
	docker build \
		-t ${TAG}:bionic-$* \
		--platform linux/$* \
		--build-arg ARCH=$* \
		--build-arg RELEASE=bionic \
		.
	docker push ${TAG}:bionic-$*

xenial/build-%:
	docker build \
		-t ${TAG}:xenial-$* \
		--platform linux/$* \
		--build-arg ARCH=$* \
		--build-arg RELEASE=xenial \
		.
	docker push ${TAG}:xenial-$*
