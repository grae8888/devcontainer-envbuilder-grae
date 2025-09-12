FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

# --- Configurable ---
ARG USERNAME=coder
ARG UID=1000
ARG GID=1000

# Base tools + rootless prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
      sudo bash ca-certificates curl gnupg lsb-release \
      uidmap slirp4netns fuse-overlayfs dbus-user-session iptables \
 && rm -rf /var/lib/apt/lists/*

# Docker repo + engine + rootless extras
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
 && chmod a+r /etc/apt/keyrings/docker.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list \
 && apt-get update && apt-get install -y --no-install-recommends \
      docker-ce docker-ce-cli containerd.io \
      docker-buildx-plugin docker-compose-plugin \
      docker-ce-rootless-extras \
 && rm -rf /var/lib/apt/lists/*

# Non-root user with sudo + userns mappings
RUN groupadd -g ${GID} ${USERNAME} \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} \
 && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/010-${USERNAME} \
 && chmod 0440 /etc/sudoers.d/010-${USERNAME} \
 && grep -q "^${USERNAME}:" /etc/subuid || echo "${USERNAME}:100000:65536" >> /etc/subuid \
 && grep -q "^${USERNAME}:" /etc/subgid || echo "${USERNAME}:100000:65536" >> /etc/subgid

# Startup script: launch rootless dockerd in foreground (Coder-compatible)
RUN bash -lc 'cat >/usr/local/bin/start-rootless-docker.sh << "EOF"\n\
#!/usr/bin/env bash\n\
set -euo pipefail\n\
export XDG_RUNTIME_DIR=/run/user/1000\n\
export DOCKER_HOST=unix:///run/user/1000/docker.sock\n\
mkdir -p \"$XDG_RUNTIME_DIR\"\n\
# one-time setup (idempotent)\n\
dockerd-rootless-setuptool.sh install --skip-iptables || true\n\
# Use vfs (works without /dev/fuse). If you can provide /dev/fuse, switch to --storage-driver=fuse-overlayfs\n\
exec dockerd-rootless.sh \\\n\
  --host=unix://$XDG_RUNTIME_DIR/docker.sock \\\n\
  --storage-driver=vfs\n\
EOF\n\
chmod +x /usr/local/bin/start-rootless-docker.sh'

# Runtime env + persistence
ENV USER=${USERNAME} HOME=/home/${USERNAME} \
    XDG_RUNTIME_DIR=/run/user/1000 \
    DOCKER_HOST=unix:///run/user/1000/docker.sock
VOLUME ["/home/${USERNAME}/.local/share/docker"]

USER ${USERNAME}
WORKDIR /home/${USERNAME}
SHELL ["/bin/bash","-lc"]

# Start rootless daemon on container boot
ENTRYPOINT ["/usr/local/bin/start-rootless-docker.sh"]
CMD []
