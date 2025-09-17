#!/usr/bin/env bash
set -euo pipefail

# Detect the target user (works when running via sudo or directly)
TARGET_USER="${SUDO_USER:-$(whoami)}"
TARGET_UID="$(id -u "$TARGET_USER")"
TARGET_GID="$(id -g "$TARGET_USER")"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

echo "[INFO] Installing Docker and rootless prerequisites..."
sudo apt-get update
sudo apt-get install -y uidmap slirp4netns iproute2 dbus-user-session \
                        curl ca-certificates gnupg lsb-release

echo "[INFO] Installing Docker (rootful engine + CLI via convenience script)..."
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sudo sh /tmp/get-docker.sh

echo "[INFO] Ensuring 'docker' group and membership (for rootful usage)..."
if ! getent group docker >/dev/null; then
  sudo groupadd docker
fi
sudo usermod -aG docker "$TARGET_USER"

echo "[INFO] Ensuring subuid/subgid ranges for rootless..."
if ! grep -q "^${TARGET_USER}:" /etc/subuid; then
  echo "${TARGET_USER}:100000:65536" | sudo tee -a /etc/subuid >/dev/null
fi
if ! grep -q "^${TARGET_USER}:" /etc/subgid; then
  echo "${TARGET_USER}:100000:65536" | sudo tee -a /etc/subgid >/dev/null
fi

echo "[INFO] Preparing per-user runtime dir..."
sudo mkdir -p "/run/user/${TARGET_UID}"
sudo chown "${TARGET_UID}:${TARGET_GID}" "/run/user/${TARGET_UID}"
sudo chmod 700 "/run/user/${TARGET_UID}"

# IMPORTANT: Do NOT call `newgrp docker` here (it changes your shell's primary GID and breaks rootless).
# The user should re-login (or start a new login shell) to pick up group changes.

# Optional helper: create a starter script for rootless Docker that guards against GID mismatch
cat <<'EOF' | sudo tee "${TARGET_HOME}/start-rootless-docker.sh" >/dev/null
#!/usr/bin/env bash
set -euo pipefail
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/docker.sock"
export PATH="/usr/bin:/sbin:/usr/sbin:${PATH}"
export ROOTLESSKIT_NET=slirp4netns  # networking backend that works well in containers

# Preflight: ensure your shell's primary GID matches /etc/passwd (avoid `newgrp` mismatch)
PW_GID="$(getent passwd "$(whoami)" | cut -d: -f4)"
ST_GID="$(id -g)"
if [ "${PW_GID}" != "${ST_GID}" ]; then
  echo "[ERROR] Primary GID mismatch (pw_gid=${PW_GID} st_gid=${ST_GID})."
  echo "        Start a fresh login shell (e.g. 'su - $(whoami)') and run this script again."
  exit 1
fi

# One-time setup (idempotent)
dockerd-rootless-setuptool.sh install --skip-iptables || true

# Launch in background
nohup dockerd-rootless.sh >"$HOME/dockerd-rootless.log" 2>&1 &
echo "Rootless dockerd started. Use:  export DOCKER_HOST=${DOCKER_HOST}"
EOF
sudo chown "${TARGET_UID}:${TARGET_GID}" "${TARGET_HOME}/start-rootless-docker.sh"
sudo chmod +x "${TARGET_HOME}/start-rootless-docker.sh"

date | sudo tee -a "${TARGET_HOME}/.docker_installed" >/dev/null
echo "[INFO] Docker installed. Log out/in to pick up 'docker' group."
echo "[INFO] For rootless, run:  ~/${TARGET_HOME##*/}/start-rootless-docker.sh  (after a fresh login shell)."
echo "Docker installed successfully!"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/docker.sock"
sudo usermod --add-subuids 165536-231071 "$USER"
sudo usermod --add-subgids 165536-231071 "$USER"
~/start-rootless-docker.sh
