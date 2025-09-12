FROM ubuntu:24.04

# --- Configurable IDs ---
ARG USER=coder
ARG UID=1000
ARG GID=1000

# Install sudo and create the user
RUN apt-get update && apt-get install -y sudo ca-certificates bash && rm -rf /var/lib/apt/lists/* \
 && groupadd -g ${GID} ${USER} \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} \
 && usermod -aG sudo ${USER} \
 && echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/010-${USER}-nopasswd \
 && chmod 0440 /etc/sudoers.d/010-${USER}-nopasswd

USER ${USER}
WORKDIR /home/${USER}
SHELL ["/bin/bash", "-lc"]
