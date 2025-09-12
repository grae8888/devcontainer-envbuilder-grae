FROM docker:27-dind-rootless

# add bash (and useful rootless deps)
USER root
RUN apk add --no-cache bash shadow-uidmap fuse-overlayfs
USER rootless

ENV DOCKER_TLS_CERTDIR=""
ENV XDG_RUNTIME_DIR=/run/user/1000
ENV DOCKER_HOST=unix:///run/user/1000/docker.sock
VOLUME ["/home/rootless/.local/share/docker"]
EXPOSE 2375
CMD ["--host=unix:///run/user/1000/docker.sock","--host=tcp://0.0.0.0:2375"]
