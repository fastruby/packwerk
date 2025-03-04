# Known Issues and Workarounds

## Overview

This document catalogs known issues encountered when backporting Packwerk from Rails 5 to Rails 3.2 and from Ruby 3 to Ruby 2.3.8, along with their workarounds. This information should help developers understand limitations, avoid common pitfalls, and quickly resolve issues they may encounter.

## Environment Issues

### Docker on M-Series Macs

| Issue | Workaround |
|-------|------------|
| Slow performance in Docker on M-series Macs | Use volume caching and limit mounted directories |
| File permission problems between host and container | Run `sudo chown -R $(id -u):$(id -g) .` on the host |
| Memory issues with Docker on M-series Macs | Increase allocated memory in Docker Desktop settings |

### Ruby 2.3.8 Installation

| Issue | Workaround |
|-------|------------|
| OpenSSL compilation issues | Install specific compatible OpenSSL version |
| Ruby installation fails with newer compilers | Use the Docker environment which has been pre-configured |
| Bundler version conflicts | Use specified Bundler version (2.2.5) |

## Rails 3.2 Compatibility Issues

### ActiveSupport

| Issue | Workaround |
|-------|------------|
| Missing `Array#to_h` method | Use `backports` gem or implement shim |
| Missing `Hash#deep_transform_keys` | Use `backports` gem or implement custom version |
| Different `delegate` behavior | Adjust delegate calls to match Rails 3.2 API |
| Missing `strip_heredoc` | Use `backports` gem or reimplement |

### Autoloading Differences

| Issue | Workaround |
|-------|------------|
| Different autoloading behavior in Rails 3.2 | Analyze and adapt to Rails 3.2 autoloading conventions |
| Missing constants during autoloading | Add explicit requires for problematic constants |
| Namespace resolution differences | Ensure class/module nesting matches file paths |

### Gem Compatibility

| Issue | Workaround |
|-------|------------|
| Newer gems require Ruby >= 2.4 | Pin to older versions or fork compatible versions |
| Native extension compilation failures | Use `--use-system-libraries` flag or pre-compiled versions |
| Transitive dependency conflicts | Lock problematic dependencies to specific versions |

## Ruby 2.3.8 Compatibility Issues

### Syntax

| Issue | Workaround |
|-------|------------|
| Pattern matching not available | Refactor to traditional conditionals |
| Endless methods not available | Convert to standard method definitions |
| Numbered parameters not available | Use explicit block parameters |
| Hash pattern syntax | Replace with explicit hash access |

### Standard Library

| Issue | Workaround |
|-------|------------|
| Missing `Dir.each_child` | Use `Dir.entries` and filter out `.` and `..` |
| Missing `Enumerable#filter_map` | Use `.select {...}.map {...}` or implement polyfill |
| Missing `Hash#except` | Implement polyfill or use alternative approach |
| Missing `JSON.load_file` | Use `JSON.parse(File.read(file))` |

## Sorbet-Related Issues

| Issue | Workaround |
|-------|------------|
| Static type checking incompatibility | Disable static type checking |
| Complex type signatures cause errors | Simplify type signatures or comment out |
| `T::Struct` with complex types | Use simpler type definitions |
| `tapioca` gem incompatibility | Manually maintain `.rbi` files if needed |

## Testing Issues

| Issue | Workaround |
|-------|------------|
| Test failures due to Rails version differences | Modify tests to use Rails 3.2 compatible assertions |
| Missing test methods from Minitest | Use alternative assertions or implement missing methods |
| Test fixtures incompatibilities | Update fixtures to match Rails 3.2 expectations |
| Mocha version compatibility issues | Pin Mocha to version 1.12.0 |

## Performance Issues

| Issue | Workaround |
|-------|------------|
| Slower autoloading in Rails 3.2 | Minimize unnecessary code loading in critical paths |
| Memory usage in Docker | Monitor and optimize memory-intensive operations |
| Slower regex performance | Simplify regex patterns where possible |
| Hash and Array operations slower | Consider performance optimizations for hot code paths |

## Debugging Tips

When encountering issues:

1. **Check Ruby Version**: Verify you're using Ruby 2.3.8 (`ruby -v`)
2. **Check Rails Version**: Verify correct Rails version (`bundle show rails`)
3. **Check Gem Environment**: Use `bundle env` to verify gem environment
4. **Container Status**: Ensure Docker container is running with `docker-compose ps`
5. **Log Level**: Increase log level with `PACKWERK_DEBUG=1` for more verbose output

## Adding New Workarounds

If you discover a new issue and implement a workaround:

1. Document the issue in this file
2. Add automated tests if possible
3. Comment any non-obvious workarounds in the code
4. Consider if the workaround should be conditionally applied based on Rails/Ruby version

## Future Resolution Paths

Some issues may be addressed in the future by:

1. Upgrading to newer patch versions of Ruby 2.3.x
2. Finding alternative gems that provide similar functionality
3. Implementing more comprehensive polyfills
4. Contributing fixes to underlying libraries 