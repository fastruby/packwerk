# Dependency Management

## Overview

This document outlines the approach to managing dependencies for the Packwerk project that has been backported from Rails 5 to Rails 3.2. Proper dependency management is critical to ensure compatibility across the backported stack while maintaining the gem's functionality.

## Gemfile and gemspec Changes

### Core Dependencies

The following core dependencies have been modified for Rails 3.2 compatibility:

1. **Rails**: Changed from `>= 5.0` to `>= 3.2`
2. **ActiveSupport**: Changed from `>= 5.0` to `>= 3.2`
3. **Ruby**: Changed from `>= 2.6` to `>= 2.3.8`

### Backporting Tools

Added dependencies to support backporting:

1. **Ruby Next**: Added to transpose newer Ruby syntax to older Ruby versions
2. **Backports**: Added to bring newer Ruby stdlib features to Ruby 2.3.8

### Commented Out Dependencies

Some dependencies have been commented out or modified:

1. **Spring**: Removed as it's not compatible with the backported setup
2. **Sorbet-related gems**: Partially commented out while maintaining runtime compatibility
3. **Tapioca**: Commented out as it's not compatible with Ruby 2.3.8

## Version Constraints

Version constraints have been carefully chosen to ensure compatibility:

```ruby
# Original
gem "rails", "~> 5"
gem "activesupport", ">= 5.0"

# Backported
gem "rails", "~> 3.2"
gem "activesupport", ">= 3.2", "< 4.0"
```

## Handling Transitive Dependencies

Transitive dependencies (dependencies of our dependencies) are managed through:

1. **Bundler Resolution**: Bundler is configured to resolve compatible versions
2. **Explicit Constraints**: Adding explicit version constraints for problematic gems
3. **Gemfile.lock**: Maintained and committed to ensure consistent dependency resolution

## Development vs Runtime Dependencies

Care has been taken to distinguish between development and runtime dependencies:

1. **Runtime Dependencies**: Essential for the gem to function
2. **Development Dependencies**: Only needed for developing the gem

## Alternative and Replacement Gems

In some cases, alternative gems have been used to provide functionality:

| Original Gem | Replacement | Reason |
|--------------|-------------|--------|
| `zeitwerk` | Classic Rails autoloading | Zeitwerk is not available in Rails 3.2 |
| `sorbet` (dev) | Commented out | Not compatible with Ruby 2.3.8 |
| `sorbet-runtime` | Pinned to specific version | Specific version works with 2.3.8 |

## Vendored Dependencies

Some dependencies have been vendored to ensure compatibility:

1. **Polyfills**: Custom polyfills for missing ActiveSupport methods
2. **Monkey Patches**: Selected monkey patches to fix compatibility issues

## Dependency Resolution

The dependency resolution process uses:

1. **Bundler**: For resolving gem dependencies
2. **Gemfile.lock**: Committed to the repository for consistency
3. **Docker**: Environment isolation to ensure clean dependency resolution

## Using Packwerk as a Dependency

When using the backported Packwerk as a dependency in other projects:

```ruby
# For Rails 3.2 projects
gem "packwerk", github: "your-org/packwerk", branch: "rails-3.2-backport"

# For Rails 5+ projects (use original)
gem "packwerk"
```

## Continuous Integration

CI is configured to:

1. Test with exact dependency versions from Gemfile.lock
2. Verify compatibility with minimum required gem versions
3. Test with the latest compatible versions of dependencies

## Best Practices

When making changes to the backported project:

1. Avoid introducing dependencies on gems requiring Ruby > 2.3.8
2. Carefully test any gem version upgrades
3. Document any special version requirements or compatibility notes
4. Use `bundle update --conservative` when updating dependencies
5. Maintain compatibility with the specified Rails and Ruby versions

## Known Dependency Issues

| Dependency | Issue | Workaround |
|------------|-------|------------|
| `nokogiri` | Native extension build issues | Use `--use-system-libraries` flag |
| `psych` | YAML parsing differences | Pin to specific version |
| `activesupport` | Method availability | Use polyfills for missing methods |

## Future Considerations

As the project evolves:

1. Regularly review for security updates to dependencies
2. Monitor for compatibility issues with new versions of Rails 3.2.x
3. Consider the maintenance burden of supporting older dependencies 