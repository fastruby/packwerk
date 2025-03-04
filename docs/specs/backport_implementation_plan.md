# Packwerk Backport Implementation Plan

## Overview

This document outlines the implementation plan for backporting Packwerk from Rails 5.x to Rails 3.2, specifically for use in a monolith application running Ruby 2.3.8 and Rails 3.2.x. Since tests are already passing for Ruby 2.3.8 with Rails 5.x, this plan focuses primarily on Rails 3.2 compatibility concerns.

## Phase 1: Analysis and Test Environment Setup

### Commit 1: `chore: set up Rails 3.2 test environment`
- Create a branch from the current Ruby 2.3.8 compatible codebase
- Set up a minimal Rails 3.2.x application for testing
- Configure test environment to use the current Ruby 2.3.8 setup
- Run existing test suite against Rails 3.2 to identify failures

**Testing approach:**
- Document all test failures with Rails 3.2
- Categorize failures by underlying cause (API differences, autoloading, etc.)

### Commit 2: `chore: analyze Rails API differences`
- Create a comprehensive list of Rails 5.x to Rails 3.2 API differences affecting the codebase
- Document Rails 3.2 alternatives for each Rails 5.x API used
- Focus analysis on autoloading mechanisms and ActiveSupport differences
- Prioritize issues based on criticality and dependency chain

**Testing approach:**
- Create specific test cases for key APIs that need adaptation
- Use isolated tests to verify Rails 3.2 behavior

## Phase 2: Core Compatibility Implementation

### Commit 3: `feat: implement ActiveSupport polyfills`
- Implement polyfills for Rails 5.x ActiveSupport methods missing in Rails 3.2
- Focus on Hash, Array, and String extension methods used in the codebase
- Use the backports gem where appropriate, implement custom polyfills where needed

```ruby
# Example implementation
module ActiveSupport
  module CoreExtensions
    module Hash
      def deep_transform_keys(&block)
        result = {}
        each do |key, value|
          result[yield(key)] = value.respond_to?(:deep_transform_keys) ? 
            value.deep_transform_keys(&block) : value
        end
        result
      end
    end
  end
end

Hash.include(ActiveSupport::CoreExtensions::Hash) unless Hash.method_defined?(:deep_transform_keys)
```

**Testing approach:**
- Create unit tests for each polyfill
- Compare behavior against Rails 5.x implementation
- Run relevant portions of existing test suite

### Commit 4: `feat: adapt Rails API usage`
- Update code using Rails 5-specific APIs to use Rails 3.2 alternatives
- Focus on direct API calls that need modification
- Implement compatibility layers for significant API differences
- Use conditional logic where needed to support both versions

**Testing approach:**
- Test each modified API call to ensure correct behavior
- Verify against both Rails 3.2 and Rails 5.x where possible

## Phase 3: Autoloading and Constant Resolution

### Commit 5: `feat: implement autoloading compatibility`
- Analyze how the current codebase handles constant loading
- Modify `ConstantDiscovery` class to work with Rails 3.2 autoloading
- Create compatibility layer for Rails 3.2 constant resolution
- Adjust file paths and naming conventions as needed

**Testing approach:**
- Create tests for constant resolution in Rails 3.2
- Verify all classes load correctly in the proper order
- Test namespace handling and nested constant resolution

### Commit 6: `feat: adapt PackageSet for Rails 3.2`
- Update the package path handling for Rails 3.2 compatibility
- Modify how packages are discovered and loaded
- Ensure proper loading order for interdependent packages
- Implement workarounds for Rails 3.2 path resolution differences

**Testing approach:**
- Test package discovery and loading
- Verify package relationships are correctly established
- Validate package boundary enforcement still works

## Phase 4: Dependency Management and Stability

### Commit 7: `chore: update gemspec and dependencies`
- Update gemspec to specify Rails 3.2 compatibility
- Pin gem dependencies to versions compatible with Rails 3.2
- Add or adjust utility gems needed for Rails 3.2 support

```ruby
# Example implementation 
spec.add_dependency("activesupport", ">= 3.2", "< 4.0")
spec.add_dependency("backports")
```

**Testing approach:**
- Test gem installation in a clean Rails 3.2 environment
- Verify all dependencies resolve properly
- Check for conflicts or version incompatibilities

### Commit 8: `fix: resolve edge cases and integration issues`
- Address remaining test failures
- Fix issues discovered during integration testing
- Implement workarounds for Rails 3.2 specific behavior
- Ensure comprehensive test coverage

**Testing approach:**
- Run the full test suite against Rails 3.2
- Fix any remaining failures
- Perform integration testing with a sample application

## Phase 5: Documentation and Finalization

### Commit 9: `docs: update documentation for Rails 3.2`
- Update README with Rails 3.2 installation instructions
- Document known limitations and workarounds
- Update API documentation to note Rails 3.2 specific behaviors
- Add troubleshooting section for common issues

**Testing approach:**
- Verify installation instructions in a clean environment
- Review documentation for accuracy and completeness

### Commit 10: `chore: prepare for release`
- Finalize version number and update changelog
- Verify full test suite passes on both Rails 3.2 and Rails 5.x
- Prepare gem for distribution
- Create release notes highlighting key changes

**Testing approach:**
- Perform final integration testing
- Validate the gem works in the target monolith application

## Technical Approach for Key Areas

### Autoloading Adaptation

Since Packwerk documentation mentions Zeitwerk (only available in Rails 6+), but the codebase has already been backported to Rails 5, we need to:

1. Analyze how the current version handles autoloading without Zeitwerk
2. Adapt the `ConstantDiscovery` and other loading mechanisms to work with Rails 3.2 autoloading
3. Address differences in how Rails 3.2 resolves constants and namespaces

### ActiveSupport Polyfills

Several ActiveSupport methods used by Packwerk are missing in Rails 3.2:

1. `Hash#deep_transform_keys`
2. `Array#to_h`
3. String methods like `strip_heredoc`

We'll implement these as needed, using the backports gem where possible and creating custom implementations when necessary.

### Rails 3.2 API Adaptation

Key Rails API differences that will need adaptation:

1. Changes in how autoload paths are configured and used
2. Differences in ActiveSupport::Concern behavior
3. Module#delegate implementation differences
4. Changes in various helper methods and utilities

## Testing Strategy

With tests already passing for Ruby 2.3.8 with Rails 5.x, our testing strategy will focus on:

1. Using the existing test suite to identify Rails 3.2 compatibility issues
2. Adding targeted tests for Rails 3.2 specific behavior
3. Ensuring all tests pass in both Rails 3.2 and Rails 5.x environments
4. Integration testing with the target monolith application 