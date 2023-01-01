FROM archlinux:base-devel

# Install pacman dependencies 
RUN pacman -Syu --noconfirm git curl lua luarocks

# Create worker user with root priviledges
RUN useradd --system --create-home worker \
  && usermod -L worker \
  && echo "worker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch users 
USER worker 
WORKDIR /home/worker

# Install yay
RUN git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg -sri --needed --noconfirm

# Clean up
RUN cd && rm -rf .cache yay

# Install excite
RUN yay --noconfirm --answerclean 1 -S excite-cli

USER root

# Install luarocks packages (DELETE LATER)
RUN luarocks install json-lua
RUN luarocks install argparse
RUN luarocks install busted
RUN luarocks install lua-curl

RUN excite -h
