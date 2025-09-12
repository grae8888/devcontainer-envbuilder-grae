# Ubuntu + rootless Docker-in-Docker that auto-starts on container boot
FROM ubuntu:24.04

ARG USERNAME=coder
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive

# ---- Base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg lsb-release sudo dbus-user-session \
    uidmap slirp4netns fuse-overlayfs iptables bash \
 && rm -rf /var/lib/apt/lists/*

# ---- Add Docker APT repo + install Docker Engine + rootless extras
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

# ---- Create non-root user with sudo and userns mappings
RUN groupadd -g ${GID} ${USERNAME} \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} \
 && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/010-${USERNAME}-nopasswd \
 && chmod 0440 /etc/sudoers.d/010-${USERNAME}-nopasswd \
 # userns mappings needed for rootless
 && grep -q "^${USERNAME}:" /etc/subuid || echo "${USERNAME}:100000:65536" >> /etc/subuid \
 && grep -q "^${USERNAME}:" /etc/subgid || echo "${USERNAME}:100000:65536" >> /etc/subgid

# ---- Startup script: launches rootless dockerd in background, then execs the given CMD
# Uses storage driver "vfs" to avoid needing /dev/fuse (works in Coder). Change to fuse-overlayfs if you add /dev/fuse later.
RUN bash -lc 'cat >/usr/local/bin/start-rootless-docker.sh << "EOF"\n\
#!/usr/bin/env bash\n\
set -euo pipefail\n\
USER_NAME='"${USERNAME}"'\n\
export XDG_RUNTIME_DIR=/run/user/1000\n\
export DOCKER_HOST=unix:///run/user/1000/docker.sock\n\
# Ensure runtime dirs exist\n\
mkdir -p \"${XDG_RUNTIME_DIR}\"\n\
# One-time setup is idempotent\n\
if ! sudo -u \"${USER_NAME}\" -E bash -lc \"dockerd-rootless-setuptool.sh check\" >/dev/null 2>&1; then\n\
  sudo -u \"${USER_NAME}\" -E dockerd-rootless-setuptool.sh install --skip-iptables || true\n\
fi\n\
# Start rootless dockerd (foreground). Use vfs to avoid /dev/fuse; switch to fuse-overlayfs if you can mount it.\n\
exec sudo -u \"${USER_NAME}\" -E dockerd-rootless.sh \\\n\
  --host=unix:///run/user/1000/docker.sock \\\n\
  --storage-driver=vfs\n\
EOF\n\
chmod +x /usr/local/bin/start-rootless-docker.sh'

# Environment for the user/CLI
ENV USER=${USERNAME} \
    HOME=/home/${USERNAME} \
    XDG_RUNTIME_DIR=/run/user/1000 \
    DOCKER_HOST=unix:///run/user/1000/docker.sock

# Persist rootless daemon data between rebuilds (optional)
VOLUME ["/home/${USERNAME}/.local/share/docker"]

# Run as the non-root user
USER ${USERNAME}
WORKDIR /home/${USERNAME}
SHELL ["/bin/bash", "-lc"]

# Start the rootless daemon when the container boots
ENTRYPOINT ["/usr/local/bin/start-rootless-docker.sh"]
# Keep it simple—Coder usually replaces CMD; if not, you'll sit on the daemon in foreground.
CMD []
