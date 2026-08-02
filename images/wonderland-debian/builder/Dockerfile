FROM debian:stable

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    debootstrap \
    ca-certificates \
    curl \
    git \
    jq \
    xz-utils \
    tar \
    sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["/bin/bash"]
