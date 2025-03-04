# Use the latest Ubuntu LTS as the base image
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install rbenv and ruby-build
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Add rbenv to PATH
ENV PATH /root/.rbenv/bin:/root/.rbenv/shims:$PATH
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# Install Ruby 2.3.8
RUN rbenv install 2.3.8 && \
    rbenv global 2.3.8

# Install bundler 1.17.3 for Rails 3.2 compatibility
RUN gem install bundler -v '1.17.3'

# Set working directory
WORKDIR /app
