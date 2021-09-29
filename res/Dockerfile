FROM docker.io/ubuntu:xenial
ENV TZ=UTC

COPY src/setup.sh .
RUN sh setup.sh && rm setup.sh
