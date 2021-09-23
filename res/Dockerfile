# Requires docker 17.05 or newer.
# For installation, see https://docs.docker.com/install/linux/docker-ce/ubuntu/
ARG BASE
FROM docker.io/ubuntu:${BASE}
ARG BASE
ENV DISTRO=${BASE}

ENV TZ=UTC

COPY build_internal.sh .
RUN sh build_internal.sh && rm build_internal.sh

WORKDIR /build
