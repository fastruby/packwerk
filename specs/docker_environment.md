# Docker Environment

## Overview

This document describes the Docker environment set up for Packwerk development. Dockerization was implemented to ensure consistent development experience across different platforms, especially for M-series Mac users, and to handle the specific requirements of running Ruby 2.3.8 with Rails 3.2.

## Docker Configuration

### Dockerfile

The Dockerfile creates an Ubuntu-based environment with Ruby 2.3.8 installed.

### Docker Compose

The docker-compose.yml file orchestrates the services needed for development.

## Usage

### Starting the Environment

To start the Docker environment:

```bash
docker-compose up -d
```

### Running Commands

To run commands in the Docker environment:

```bash
docker-compose exec app bash
```

Once inside the container:

```bash
bundle install
bundle exec rake test
```

### Shortcuts

Consider adding these aliases to your shell configuration for easier access:

```bash
alias packwerk-docker="docker-compose -f /path/to/packwerk/docker-compose.yml"
alias packwerk-shell="packwerk-docker exec app bash"
alias packwerk-test="packwerk-docker exec app bundle exec rake test"
```

## Environment Variables

The Docker environment includes these environment variables:

| Variable | Purpose |
|----------|---------|
| BUNDLE_PATH | Specifies where gems are installed |
| BUNDLE_BIN | Specifies where binstubs are installed |
| GEM_HOME | Sets the gem home directory |

## Volume Management

The Docker Compose setup includes a volume for gem caching to improve performance between container restarts.

## M-Series Mac Considerations

For M-series Mac users, the Docker environment addresses several specific challenges:

1. **Architecture Differences**: The Docker image runs in x86_64 emulation mode on ARM-based Macs
2. **Performance Optimization**: Volume mounting is configured for optimal performance
3. **Native Extensions**: The environment includes necessary dependencies for compiling native extensions

## Known Issues

1. **Performance**: Running in emulation mode on M-series Macs may result in slower performance
2. **Filesystem Sync**: Occasional issues with file syncing between host and container may occur

## Troubleshooting

### Gem Installation Issues

If you encounter issues with gem installation:

```bash
# Inside the container
gem install bundler -v '2.2.5'
bundle config build.nokogiri --use-system-libraries
bundle install
```

### Permission Issues

For permission issues with mounted volumes:

```bash
# On host
sudo chown -R $(id -u):$(id -g) .
```

### Container Won't Start

If the container fails to start:

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
``` 