# Docker-outside-of-Docker (DooD) on Ubuntu 22.04
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base tools + Docker CLI
RUN apt-get update \
 && apt-get install -y curl ca-certificates gnupg lsb-release sudo gosu \
 && install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
 && chmod a+r /etc/apt/keyrings/docker.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y docker-ce-cli \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create user 'coder' (UID/GID auto-assigned)
RUN groupadd -r coder \
 && useradd -m -s /bin/bash -g coder coder \
 && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/010-coder-nopasswd \
 && chmod 0440 /etc/sudoers.d/010-coder-nopasswd

COPY coder-socket-access.sh .
RUN chmod +x ./coder-socket-access.sh

WORKDIR /workspaces
