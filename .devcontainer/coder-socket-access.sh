#!/usr/bin/env bash

set -euo pipefail

SOCK=/var/run/docker.sock

if [ -S "$SOCK" ]; then
  gid="$(stat -c %g "$SOCK")"
  getent group "$gid" >/dev/null 2>&1 || groupadd -g "$gid" dockersock || true
  grp="$(getent group "$gid" | cut -d: -f1 || true)"
  [ -n "$grp" ] && usermod -aG "$grp" coder || true
fi

exec gosu coder "$@"
