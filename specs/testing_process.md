# Testing Process

## Overview

This document outlines the testing process for the backported Packwerk project. The testing approach has been adapted to accommodate the backporting from Rails 5 to Rails 3.2 and the shift to a Docker-based development environment.

## Testing Environment

All tests for the backported Packwerk project are run within the Docker container to ensure a consistent testing environment. This is particularly important given the specific Ruby (2.3.8) and Rails (3.2) versions required.

## Running the Test Suite

### Full Test Suite

To run the entire test suite:

```bash
# From within the Docker container
bundle exec rake test
```

### Running Specific Tests

To run a specific test file:

```bash
bundle exec ruby -I test test/path/to/test_file.rb
```

To run a specific test:

```bash
bundle exec ruby -I test test/path/to/test_file.rb -n test_name
```

Using the M test runner for more convenient test running:

```bash
bundle exec m test/path/to/test_file.rb:line_number
```

## Test Structure

The test suite is organized as follows:

- `test/unit/`: Unit tests for individual components
- `test/integration/`: Integration tests for component interactions
- `test/system/`: End-to-end tests for the entire system

## Testing Framework

The project uses Test::Unit (Minitest) as its testing framework. Key components include:

- **Mocha**: For mocking and stubbing
- **Minitest::Focus**: For focusing on specific tests during development
- **Custom Test Helpers**: Located in `test/test_helper.rb`

## Writing Tests

When writing tests for the backported project, keep in mind:

1. **Rails 3.2 Compatibility**: Tests should only use Rails 3.2 compatible APIs
2. **Ruby 2.3.8 Syntax**: Avoid newer Ruby syntax features not available in 2.3.8
3. **Docker Environment**: Tests must run correctly in the Docker environment

### Test Structure Example

```ruby
require "test_helper"

module Packwerk
  class SomeClassTest < Minitest::Test
    def setup
      # Setup test environment
      @subject = SomeClass.new
    end

    def teardown
      # Clean up after test
    end

    def test_some_method_behaves_correctly
      # Arrange
      expected_result = "expected"
      
      # Act
      result = @subject.some_method
      
      # Assert
      assert_equal expected_result, result
    end
  end
end
```

## Testing Backported Features

For features that were specifically backported, include tests that:

1. Verify the feature works correctly in Rails 3.2
2. Test edge cases specific to Rails 3.2 behavior
3. Validate any polyfills or shims implemented during backporting

## Continuous Integration

The CI setup has been adapted to run tests in a Docker environment similar to the local development setup:

1. Tests run on every pull request
2. Tests are executed in a Ruby 2.3.8 environment
3. Both unit and integration tests are run

## Test Coverage

Test coverage is monitored to ensure the backported codebase maintains high test coverage. Consider using the SimpleCov gem to track coverage metrics.

## Troubleshooting Tests

### Common Test Issues

1. **Slow Tests**: 
   - Tests may run slower in the Docker environment, especially on M-series Macs
   - Consider using `minitest-focus` to focus on specific tests during development

2. **Rails Version Mismatches**:
   - Ensure all test fixtures and factories are compatible with Rails 3.2
   - Check for usage of Rails helpers or methods that don't exist in 3.2

3. **Ruby Version Issues**:
   - Watch for syntax errors related to Ruby 2.3.8 compatibility
   - Ensure all gems in the test group are compatible with Ruby 2.3.8

4. **File Permission Issues**:
   - Test files created during testing may have permission issues
   - Run `sudo chown -R $(id -u):$(id -g) .` on the host if needed

### Debugging Tests

For difficult-to-debug test issues:

```ruby
# Add debug output to tests
puts "Debug value: #{some_value.inspect}"

# Use byebug for interactive debugging
require 'byebug'
byebug # Add this line where you want to stop execution
```

## Best Practices

1. Write tests for all new features and bug fixes
2. Make tests as concise and focused as possible
3. Follow the Arrange-Act-Assert pattern for clarity
4. Organize tests to mirror the structure of the code being tested
5. Use meaningful test names that describe the behavior being tested
6. Keep tests independent of each other (avoid test interdependencies) 