# Build:
# docker build -t amedice/mean .
#
# Run:
# docker run -it amedice/mean
#
# Compose:
# docker-compose up -d

FROM ubuntu:latest
MAINTAINER MEAN.JS

# 80 = HTTP, 443 = HTTPS, 3000 = MEAN.JS server, 35729 = livereload, 8080 = node-inspector
EXPOSE 80 443 3000 35729 8080

# Set development environment as default
ENV NODE_ENV development

# Install Utilities
RUN apt-get update -q  \
 && apt-get install -yqq curl \
 wget \
 aptitude \
 htop \
 vim \
 git \
 traceroute \
 dnsutils \
 curl \
 ssh \
 tree \
 tcpdump \
 nano \
 psmisc \
 gcc \
 make \
 build-essential \
 libfreetype6 \
 libfontconfig \
 libkrb5-dev \
 ruby \
 sudo \
 apt-utils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
RUN sudo apt-get install -yq nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install MEAN.JS Prerequisites
RUN npm install --quiet -g gulp bower yo generator-meanjs mocha karma-cli pm2 && npm cache clean

# Create workspace
RUN useradd -ms /bin/bash meanjs sudo
RUN mkdir -p /home/meanjs/public/lib
USER meanjs
WORKDIR /home/meanjs

# Copies the local package.json file to the container
# and utilities docker container cache to not needing to rebuild
# and install node_modules/ everytime we build the docker, but only
# when the local package.json file changes.
# Install npm packages
COPY package.json /home/meanjs/package.json
RUN npm install --quiet && npm cache clean

# Install bower packages
COPY bower.json /home/meanjs/bower.json
COPY .bowerrc /home/meanjs/.bowerrc
RUN bower install --quiet --allow-root --config.interactive=false

COPY . /home/meanjs

# Run MEAN.JS server
CMD ["npm", "start"]
