# Docker-outside-of-Docker (no build args)
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Base deps + Docker CLI (no daemon) + gosu (to drop privileges cleanly)
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

# Create a regular user 'coder' with passwordless sudo (UID/GID auto-assigned)
RUN groupadd -r coder \
 && useradd -m -s /bin/bash -g coder coder \
 && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/010-coder-nopasswd \
 && chmod 0440 /etc/sudoers.d/010-coder-nopasswd

WORKDIR /workspaces

# Entry script:
# - Detect mounted Docker socket (rootful: /var/run/docker.sock; rootless varies)
# - Match the socket's GID with a group inside; add 'coder' to it
# - Drop to 'coder' and exec the given command (default: bash)
RUN printf '%s\n' \
'#!/usr/bin/env bash' \
'set -euo pipefail' \
': "${DOCKER_SOCK_PATH:=/var/run/docker.sock}"' \
'if [ -S "$DOCKER_SOCK_PATH" ]; then' \
'  gid="$(stat -c %g "$DOCKER_SOCK_PATH")"' \
'  # Create a group with that GID if none exists' \
'  if ! getent group "$gid" >/dev/null 2>&1; then' \
'    groupadd -g "$gid" dockersock 2>/dev/null || true' \
'  fi' \
'  # Determine group name for the GID (new or existing)' \
'  grp="$(getent group "$gid" | cut -d: -f1 || true)"' \
'  [ -n "$grp" ] && usermod -aG "$grp" coder || true' \
'fi' \
'exec gosu coder "$@"' > /usr/local/bin/dood-entrypoint.sh \
 && chmod +x /usr/local/bin/dood-entrypoint.sh

# Run the entrypoint as root; it will drop to 'coder'
ENTRYPOINT ["/usr/local/bin/dood-entrypoint.sh"]
CMD ["bash"]
