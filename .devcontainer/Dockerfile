FROM ubuntu:24.04

# ---- Configurable ----
ARG USERNAME=coder
ARG UID=1000
ARG GID=1000

# Create user/group and passwordless sudo
RUN apt-get update && apt-get install -y --no-install-recommends sudo ca-certificates bash \
 && groupadd --gid ${GID} ${USERNAME} \
 && useradd --uid ${UID} --gid ${GID} -m -s /bin/bash ${USERNAME} \
 && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/010-${USERNAME}-nopasswd \
 && chmod 0440 /etc/sudoers.d/010-${USERNAME}-nopasswd \
 && rm -rf /var/lib/apt/lists/*

# Make sure $USER and $HOME are set at runtime (some tools rely on these)
ENV USER=${USERNAME} \
    HOME=/home/${USERNAME}

WORKDIR /home/${USERNAME}
USER ${USERNAME}
SHELL ["/bin/bash", "-lc"]
