#FROM archlinux:latest
FROM archlinux:base-devel

# Install dependencies 
RUN pacman -Syu --noconfirm git

# makepkg user and workdir
#ARG user=makepkg
RUN useradd --system --create-home build \
  && usermod -L build

RUN echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER build
WORKDIR /home/build

# Install yay
RUN git clone https://aur.archlinux.org/yay.git

RUN cd yay && makepkg -sri --needed --noconfirm

# Clean up
RUN cd && rm -rf .cache yay
