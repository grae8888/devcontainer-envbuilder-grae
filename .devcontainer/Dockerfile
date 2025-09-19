FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*

ARG USERNAME=coder
ARG UID=1000
ARG GID=1000

RUN groupadd -g ${GID} ${USERNAME} \
 && useradd -m -s /bin/bash -u ${UID} -g ${GID} ${USERNAME} \
 && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/010-${USERNAME}-nopasswd \
 && chmod 0440 /etc/sudoers.d/010-${USERNAME}-nopasswd

USER ${USERNAME}
WORKDIR /home/${USERNAME}
