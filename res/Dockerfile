ARG ARCH=amd64
ARG RELEASE=xenial
FROM docker.io/${ARCH}/ubuntu:${RELEASE}
LABEL org.opencontainers.image.source "https://github.com/RyanHir/toolchain-builder"
ENV TZ=UTC

COPY src/setup.sh .
RUN sh setup.sh && rm setup.sh

