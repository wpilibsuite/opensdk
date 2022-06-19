FROM docker.io/ubuntu:bionic
LABEL org.opencontainers.image.source "https://github.com/wpilibsuite/opensdk"
ENV TZ=UTC

COPY src/setup.sh src/setup_opensysroot.sh /
ADD src/opensysroot /opensysroot
RUN sh setup.sh && sh setup_opensysroot.sh && rm setup.sh setup_opensysroot.sh
