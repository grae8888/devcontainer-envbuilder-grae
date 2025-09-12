# Rootless Docker-in-Docker
FROM docker:27-dind-rootless

# Install handy tools and ensure required paths/ownership exist at boot
USER root
RUN apk add --no-cache bash shadow-uidmap fuse-overlayfs curl \
 && mkdir -p /run/user/1000 \
 && chown rootless:rootless /run/user/1000 \
 && chmod 700 /run/user/1000 \
 && mkdir -p /home/rootless/.local/share/docker \
 && chown -R rootless:rootless /home/rootless/.local/share/docker
USER rootless

# Rootless daemon + CLI defaults
ENV DOCKER_TLS_CERTDIR=""
ENV XDG_RUNTIME_DIR=/run/user/1000
ENV DOCKER_HOST=unix:///run/user/1000/docker.sock

# Persist daemon data; optional TCP (insecure if exposed broadly)
VOLUME ["/home/rootless/.local/share/docker"]
EXPOSE 2375

# Keep the image's entrypoint; just pass dockerd hosts
CMD ["--host=unix:///run/user/1000/docker.sock","--host=tcp://0.0.0.0:2375"]

# Healthcheck proves the inner daemon is up after restart
HEALTHCHECK --interval=10s --timeout=3s --start-period=20s --retries=3 \
  CMD /bin/sh -lc "wget -qO- http://127.0.0.1:2375/_ping 2>/dev/null | grep -q '^OK$' || exit 1"
