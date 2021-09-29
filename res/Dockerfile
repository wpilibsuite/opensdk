FROM docker.io/ubuntu:xenial
ENV TZ=UTC

COPY build_internal.sh .
RUN sh build_internal.sh && rm build_internal.sh

WORKDIR /build
