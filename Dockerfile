# syntax=docker/dockerfile:1
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    binfmt-support \
    binwalk \
    ca-certificates \
    cpio \
    cryptsetup \
    curl \
    debootstrap \
    e2fsprogs \
    fdisk \
    file \
    git \
    gnupg \
    gzip \
    kmod \
    lz4 \
    mount \
    pcregrep \
    procps \
    pv \
    python3 \
    qemu-user-static \
    sudo \
    tar \
    unzip \
    util-linux \
    vboot-utils \
    wget \
    xz-utils \
    zip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/shimboot
COPY . /opt/shimboot
COPY docker/shimboot-docker-entrypoint /usr/local/bin/shimboot-docker-entrypoint
RUN chmod +x /usr/local/bin/shimboot-docker-entrypoint \
  && mkdir -p /data

VOLUME ["/data"]
ENTRYPOINT ["shimboot-docker-entrypoint"]
CMD ["--help"]
