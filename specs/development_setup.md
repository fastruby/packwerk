# Development Setup

## Overview

This document outlines the development setup process for working with the backported Packwerk project. The setup has been changed from the original process due to the backporting from Rails 7/5 to Rails 3.2 and Ruby 3 to Ruby 2.3.8, as well as the addition of Docker for environment consistency.

## Prerequisites

Before setting up the development environment, ensure you have:

1. **Docker and Docker Compose** installed on your system
2. **Git** for cloning the repository
3. A text editor or IDE of your choice

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/your-org/packwerk.git
cd packwerk
```

### Start the Docker Environment

```bash
docker-compose up -d
```

### Enter the Docker Container

```bash
docker-compose exec app bash
```

### Install Dependencies

Once inside the container:

```bash
bundle install
```

## Development Workflow

### Running Tests

Run the test suite to ensure everything is working:

```bash
bundle exec rake test
```

### Running Specific Tests

To run a specific test:

```bash
bundle exec ruby -I test test/path/to/test_file.rb
```

Or using the M test runner:

```bash
bundle exec m test/path/to/test_file.rb:line_number
```

### Formatting Code

The project uses RuboCop for code style enforcement:

```bash
bundle exec rubocop
```

### Making Changes

1. Create a new branch:
   ```bash
   git checkout -b your-feature-branch
   ```

2. Make your changes in the Docker container
   * Code will be automatically synced between your host machine and the container

3. Run tests to verify changes:
   ```bash
   bundle exec rake test
   ```

4. Commit and push your changes:
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin your-feature-branch
   ```

## Key Differences from Original Setup

The following highlights the key differences between the original and backported development setup:

1. **Docker Requirement**: The development environment now runs in Docker to ensure consistency
2. **No Spring**: Spring has been removed from the project
3. **Ruby Version**: Development now uses Ruby 2.3.8 instead of Ruby 3+
4. **Rails Version**: Development targets Rails 3.2 instead of Rails 5+
5. **Testing Process**: Tests must be run inside the Docker container

## IDE Integration

### VS Code

For VS Code users, consider adding these settings to `.vscode/settings.json`:

```json
{
  "ruby.useBundler": true,
  "ruby.useLanguageServer": true,
  "ruby.lint": {
    "rubocop": {
      "useBundler": true
    }
  },
  "ruby.format": "rubocop",
  "terminal.integrated.defaultProfile.linux": "bash",
  "terminal.integrated.profiles.linux": {
    "bash": {
      "path": "bash",
      "args": ["-l"]
    }
  }
}
```

### JetBrains RubyMine/IDEA

For RubyMine or IntelliJ IDEA users:

1. Configure the Ruby SDK to use Docker Compose:
   * Go to Preferences > Languages & Frameworks > Ruby SDK and Gems
   * Add a new remote SDK using Docker Compose
   * Specify the service name as "app"

2. Configure the Test Runner:
   * Go to Preferences > Tools > Ruby Test Runner
   * Set "Test framework" to "Test::Unit"
   * Check "Use Docker Compose" and select your docker-compose.yml

## Troubleshooting

### Common Issues

1. **Gem Installation Failures**:
   ```bash
   bundle config build.nokogiri --use-system-libraries
   bundle install
   ```

2. **Permission Issues**:
   ```bash
   # On the host machine
   sudo chown -R $(id -u):$(id -g) .
   ```

3. **Docker Sync Issues**:
   Restart the container:
   ```bash
   docker-compose restart
   ```

4. **Test Failures**:
   Ensure you're running in the correct environment:
   ```bash
   echo $RAILS_ENV
   # Should return "test" or be unset
   ```

## Best Practices

1. Always run tests before committing changes
2. Use the Docker environment for consistency
3. Be aware of Rails 3.2 and Ruby 2.3.8 limitations
4. Document any workarounds implemented for backporting issues 