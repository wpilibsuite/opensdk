FROM docker.io/ubuntu:bionic
LABEL org.opencontainers.image.source "https://github.com/RyanHir/toolchain-builder"
ENV TZ=UTC

COPY src/setup.sh .
RUN sh setup.sh && rm setup.sh

