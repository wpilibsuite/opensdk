TAG=ghcr.io/ryanhir/toolchain-builder:latest
.PHONY: build pull push

build: pull
	docker build -t ${TAG} .
pull:
	docker pull ${TAG} || true
push:
	docker push ${TAG}

