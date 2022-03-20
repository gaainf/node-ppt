# Build base image
ARG VERSION=16-bullseye-slim
FROM node:${VERSION} AS base

RUN mkdir -p /usr/src/app
RUN chmod -R 777 /usr/src/app
WORKDIR /usr/src/app

RUN  apt-get update \
    && apt-get install -y wget gnupg ca-certificates procps libxss1
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    # the last available stable chromium:arm64 version is 90
    # && sh -c 'echo "deb http://ftp.ru.debian.org/debian sid main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y libgbm-dev libxkbcommon-x11-0 libgtk-3-0
RUN apt-get install -y chromium
# RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# RUN dpkg -i ./google-chrome-stable_current_amd64.deb

ARG NODE_OPTIONS=--max_old_space_size=8192
ENV NODE_OPTIONS=${NODE_OPTIONS}
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true 
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Configure kernel to avoid no-sanbox error
RUN echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/userns.conf

RUN apt-get update && apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

ARG USERNAME=appuser
ENV USERNAME=${USERNAME}
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd -f -g ${USER_UID} ${USER_UID}
RUN useradd -o -u ${USER_UID} -g ${USER_UID} -s /bin/bash -m ${USERNAME}
    
# Add sudo support
RUN apt-get update \
    && apt-get install -y sudo \
    && sudo passwd -d root \
    && echo "root ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USERNAME}

ENTRYPOINT ["/bin/bash"]