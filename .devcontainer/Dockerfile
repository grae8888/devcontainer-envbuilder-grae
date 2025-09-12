# Runs dockerd inside the container
FROM docker:27-dind

# --- Configurable IDs ---
ARG USER=coder
ARG UID=1000
ARG GID=1000

# Disable TLS for simplicity (use TLS in prod if you need remote access)
ENV DOCKER_TLS_CERTDIR=""

# Install sudo + bash and create 'coder' with passwordless sudo
RUN apk add --no-cache bash sudo \
 && addgroup -g ${GID} ${USER} \
 && adduser  -D -G ${USER} -u ${UID} -h /home/${USER} -s /bin/bash ${USER} \
 && addgroup ${USER} docker \
 && addgroup ${USER} wheel \
 && printf '%%wheel ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/010-wheel-nopasswd

# Expose the non-TLS dockerd port (since DOCKER_TLS_CERTDIR is empty)
EXPOSE 2375
VOLUME /var/lib/docker
