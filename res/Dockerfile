FROM docker.io/ubuntu:xenial
ARG BASE
ENV DISTRO=${BASE}

ENV TZ=UTC

COPY build_internal.sh .
RUN sh build_internal.sh && rm build_internal.sh

WORKDIR /build
