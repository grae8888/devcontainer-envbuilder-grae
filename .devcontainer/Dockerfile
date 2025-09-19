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
RUN chmod +x /coder-socket-access.sh

WORKDIR /workspaces

USER coder

# USER coder

# Entrypoint ensures coder can access mounted docker.sock
# RUN printf '%s\n' \
# '#!/usr/bin/env bash' \
# 'set -euo pipefail' \
# ': "${DOCKER_SOCK_PATH:=/var/run/docker.sock}"' \
# 'if [ -S "$DOCKER_SOCK_PATH" ]; then' \
# '  gid="$(stat -c %g "$DOCKER_SOCK_PATH")"' \
# '  if ! getent group "$gid" >/dev/null 2>&1; then' \
# '    groupadd -g "$gid" dockersock 2>/dev/null || true' \
# '  fi' \
# '  grp="$(getent group "$gid" | cut -d: -f1 || true)"' \
# '  [ -n "$grp" ] && usermod -aG "$grp" coder || true' \
# 'fi' \
# 'exec gosu coder "$@"' > /usr/local/bin/dood-entrypoint.sh \
#  && chmod +x /usr/local/bin/dood-entrypoint.sh

# ENTRYPOINT ["/usr/local/bin/dood-entrypoint.sh"]
# CMD ["bash"]
