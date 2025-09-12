# Rootless Docker-in-Docker
FROM docker:27-dind-rootless

# (Optional) extras; image already includes what's needed for rootless,
# but bash/fuse-overlayfs/uidmap are harmless to ensure availability.
RUN apk add --no-cache bash shadow-uidmap fuse-overlayfs

# Disable TLS and point the CLI to the rootless socket
ENV DOCKER_TLS_CERTDIR=""
ENV XDG_RUNTIME_DIR=/run/user/1000
ENV DOCKER_HOST=unix:///run/user/1000/docker.sock

# Persist daemon data
VOLUME ["/home/rootless/.local/share/docker"]

# Optional TCP listener (INSECURE if published beyond localhost)
EXPOSE 2375

# Pass flags to the image’s entrypoint (dockerd-rootless.sh)
# Keeps unix socket + adds tcp listener (remove the tcp host if you don't need it)
CMD ["--host=unix:///run/user/1000/docker.sock", "--host=tcp://0.0.0.0:2375"]
