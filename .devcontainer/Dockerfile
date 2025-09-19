FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*

ARG USERNAME=coder
ARG UID=1000
ARG GID=1000

RUN groupadd -g 1000 coder \
 && useradd -m -s /bin/bash -u 1000 -g 1000 coder \
 && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/010-coder-nopasswd \
 && chmod 0440 /etc/sudoers.d/010-coder-nopasswd

USER coder
WORKDIR /workspaces
