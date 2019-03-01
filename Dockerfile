### first stage - builder ###
FROM golang:1.12 as builder

MAINTAINER Maciej Pijanowski <maciej.pijanowski@3mdeb.com>

ENV HOME=/scratch

# install debos build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libglib2.0-dev \
    libostree-dev \
    && rm -rf /var/lib/apt/lists/*

RUN go get -d github.com/go-debos/debos/cmd/debos
WORKDIR /go/src/github.com/go-debos/debos/
RUN GOOS=linux go build -a cmd/debos/debos.go

### second stage - runner ###
FROM debian:testing-slim as runner

ARG DEBIAN_FRONTEND=noninteractive

# debos runtime dependencies
# ca-certificates is required to validate HTTPS certificates when getting debootstrap release file
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libostree-1-1 \
    ca-certificates \
    debootstrap \
    systemd-container \
    binfmt-support \
    parted \
    dosfstools \
    e2fsprogs \
    bmap-tools \
    # fakemachine runtime dependencies
    qemu-system-x86 \
    qemu-user-static \
    busybox \
    linux-image-amd64 \
    systemd \
    dbus \
    unzip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /go/src/github.com/go-debos/debos/debos /usr/bin/debos

WORKDIR /root
