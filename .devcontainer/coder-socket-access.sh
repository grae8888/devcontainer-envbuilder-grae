#!/usr/bin/env bash
set -euo pipefail

# Ensure we're root (re-exec via sudo if not)
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  exec sudo -E bash "$0"
fi

SOCK=/var/run/docker.sock

if [ -S "$SOCK" ]; then
  gid="$(stat -c %g "$SOCK")"
  getent group "$gid" >/dev/null 2>&1 || groupadd -g "$gid" dockersock || true
  grp="$(getent group "$gid" | cut -d: -f1 || true)"
  [ -n "$grp" ] && usermod -aG "$grp" coder || true
fi
