FROM docker.io/ubuntu:bionic
LABEL org.opencontainers.image.source "https://github.com/RyanHir/toolchain-builder"
ENV TZ=UTC

COPY src/setup.sh src/setup_opensysroot.sh /
RUN sh setup.sh && sh setup_opensysroot.sh && rm setup.sh setup_opensysroot.sh
