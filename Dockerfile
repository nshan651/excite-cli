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

# Pull src and run tests
#RUN git clone https://github.com/nshan651/excite-cli.git \
#    && cd excite-cli/src/test \
#    && busted test_fixtures.lua

# Install excite
RUN yay --noconfirm --answerclean 1 -S excite-cli

RUN excite -h
#USER root

#RUN luarocks install lua-curl \
#    && luarocks install busted \
#    && luarocks install argparse

