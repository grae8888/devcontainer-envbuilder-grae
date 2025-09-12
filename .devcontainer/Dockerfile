# Rootless Docker-in-Docker
FROM docker:27-dind-rootless

# Disable TLS; point CLI to the rootless socket
ENV DOCKER_TLS_CERTDIR=""
ENV XDG_RUNTIME_DIR=/run/user/1000
ENV DOCKER_HOST=unix:///run/user/1000/docker.sock

# Persist rootless daemon data
VOLUME ["/home/rootless/.local/share/docker"]

# Optional TCP listener (INSECURE if exposed beyond localhost)
EXPOSE 2375

# Use the image’s entrypoint (dockerd-rootless.sh) and add hosts
CMD ["--host=unix:///run/user/1000/docker.sock","--host=tcp://0.0.0.0:2375"]
