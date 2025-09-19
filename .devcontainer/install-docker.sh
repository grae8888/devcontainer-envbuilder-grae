#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${SUDO_USER:-$(whoami)}"

echo "[INFO] Installing Docker Engine (rootful)…"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key & repo
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update
sudo apt-get install -y \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create docker group and add your user (so you can run docker without sudo)
if ! getent group docker >/dev/null; then
  sudo groupadd docker
fi
sudo usermod -aG docker "$TARGET_USER"

# Start the rootful daemon
if command -v systemctl >/dev/null 2>&1; then
  echo "[INFO] Detected systemd; enabling and starting docker.service…"
  sudo systemctl enable --now docker
else
  echo "[INFO] No systemd detected; starting dockerd in the background…"
  # Optional: write a basic daemon.json (safe defaults)
  sudo mkdir -p /etc/docker
  if [[ ! -f /etc/docker/daemon.json ]]; then
    echo '{"iptables": true, "log-driver": "json-file", "log-opts": {"max-size": "10m", "max-file": "3"}}' \
      | sudo tee /etc/docker/daemon.json >/dev/null
  fi
  # Launch dockerd rootfully
  sudo nohup dockerd -H unix:///var/run/docker.sock \
    >>/var/log/dockerd.log 2>&1 &
  # Wait for the socket
  echo -n "[INFO] Waiting for docker socket"
  for i in {1..30}; do
    [[ -S /var/run/docker.sock ]] && break
    echo -n "."
    sleep 1
  done
  echo
fi

echo "[INFO] Docker Engine is installed (rootful). You may need to re-login for group membership to apply."
echo "[INFO] Test with:   docker run --rm hello-world"

