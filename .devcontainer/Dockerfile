FROM ubuntu

RUN apt-get update && apt-get install -y vim sudo curl && rm -rf /var/lib/apt/lists/*

# Create user in 'sudo' group and allow passwordless sudo
RUN useradd -m -s /bin/bash -G sudo coder \
 && echo 'coder ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/010-coder-nopasswd \
 && chmod 0440 /etc/sudoers.d/010-coder-nopasswd

# Fancy prompt
RUN echo "PS1='🐳 \[\033[1;36m\]\h \[\033[1;34m\]\W\[\033[0;35m\] \[\033[1;36m\]# \[\033[0m\]'" > /home/coder/.bashrc \
 && chown coder:coder /home/coder/.bashrc

USER coder
