# Backport Implementation Details

## Overview

This document provides detailed technical information about how specific backporting changes were implemented when adapting Packwerk from Rails 5 to Rails 3.2 and Ruby 3 to Ruby 2.3.8. It serves as a reference for developers working on the project, particularly when troubleshooting issues or implementing new features.

## Previous Backports

Prior to the Rails 3.2 backport, the project had already undergone several backporting steps:

1. Rails 7 alpha → Rails 5.x
2. Ruby 3 → Ruby 2.3.8
3. Dockerization for compatibility with M-series Macs
4. Removal of Spring

## Code Transpilation with Ruby Next

### Implementation Details

Ruby Next is used to transpile newer Ruby syntax to Ruby 2.3.8-compatible code. The implementation includes:

1. **Runtime Transpilation**: Code is transpiled at runtime in development
2. **Build-time Transpilation**: A rake task transpiles code before distribution

```ruby
# In lib/packwerk.rb
require 'ruby-next/language/runtime' if RUBY_VERSION < '2.4'

# Configuration for Ruby Next
RubyNext::Language.features = %i[
  pattern_matching
  endless_method
  rightward_assignment
  args_forward
  numbered_params
]
```

## Autoloading Compatibility

### Implementation Details

Although the Packwerk README mentions Zeitwerk as a prerequisite (which is only available in Rails 6+), our version (2.1.1) has already been backported from Rails 7 to Rails 5, suggesting autoloading compatibility has been addressed. Our approach includes:

1. **Analyzing Current Implementation**:
   ```ruby
   # First, examine how the current version loads its classes and constants
   # Look for require statements, autoload declarations, or custom loading logic
   ```

2. **Adapting to Rails 3.2 Autoloading**:
   ```ruby
   # After identifying how autoloading works in the current codebase,
   # implement targeted changes for Rails 3.2 compatibility
   # This may involve explicit requires or adjusting load paths
   ```

3. **Testing Constant Resolution**:
   Verifying that all classes and constants are properly resolved in Rails 3.2

## ActiveSupport Polyfills

### Implementation Details

Many ActiveSupport methods used by Packwerk are missing in Rails 3.2. The backport includes:

```ruby
# lib/packwerk/ext/active_support_extensions.rb
module ActiveSupport
  module CoreExtensions
    module Hash
      # Backport of Hash#deep_transform_keys from newer Rails
      def deep_transform_keys(&block)
        result = {}
        each do |key, value|
          result[yield(key)] = value.respond_to?(:deep_transform_keys) ? 
            value.deep_transform_keys(&block) : value
        end
        result
      end
      
      # Other backported methods
    end
    
    # Other extensions
  end
end

# Apply extensions
Hash.include(ActiveSupport::CoreExtensions::Hash) unless Hash.method_defined?(:deep_transform_keys)
# Other includes as needed
```

## Rails 3.2 API Adaptations

### Implementation Details

The codebase required adaptations to work with Rails 3.2 APIs:

1. **Module#delegate Changes**:
   ```ruby
   # Original in Rails 5
   delegate :method1, :method2, to: :target, allow_nil: true
   
   # Backported for Rails 3.2
   delegate :method1, :method2, to: :target, allow_nil: true # Rails 3.2 supports this
   ```

2. **ActiveSupport::Concern Usage**:
   Some usages needed adjustment to work with the Rails 3.2 version.

## Sorbet Modifications

### Implementation Details

Sorbet integration required several modifications:

1. **Type Signature Simplification**:
   ```ruby
   # Original
   sig { params(files: T::Array[String], options: T::Hash[Symbol, T.untyped]).void }
   
   # Backported
   sig { params(files: T::Array, options: T::Hash).void }
   ```

2. **Runtime Type Check Adjustments**:
   Some runtime type checks were modified to work with the pinned sorbet-runtime version.

3. **T::Struct Simplification**:
   Complex T::Struct definitions were simplified.

## Dependency Management

### Implementation Details

1. **Gemfile Modifications**:
   ```ruby
   # Original
   gem "rails", "~> 5"
   gem "sorbet"
   gem "spring"
   
   # Backported
   gem "rails", "~> 3.2"
   gem "sorbet-runtime", "0.5.10461"
   # spring removed
   ```

2. **Gemspec Adjustments**:
   ```ruby
   # Original
   spec.add_dependency("activesupport", ">= 5.0")
   spec.required_ruby_version = ">= 2.6.0"
   
   # Backported
   spec.add_dependency("activesupport", ">= 3.2", "< 4.0")
   spec.add_dependency("ruby-next")
   spec.add_dependency("backports")
   spec.required_ruby_version = ">= 2.3.8"
   ```

## Docker Environment

### Implementation Details

The Docker environment was set up with:

1. **Ubuntu 22.04 Base**: Chosen for compatibility with required libraries
2. **rbenv**: Used to install and manage Ruby 2.3.8
3. **Volume Mounting**: Configured for code editing on host machine
4. **Gem Caching**: Implemented via Docker volumes

## Testing Adaptations

### Implementation Details

1. **Test Helper Modifications**:
   ```ruby
   # test/test_helper.rb
   # Rails 3.2 compatible test setup
   require 'active_support/test_case'
   
   # Polyfills for missing test methods
   class ActiveSupport::TestCase
     # Add missing assertion methods
   end
   ```

2. **Mocha Configuration**:
   ```ruby
   # Configure Mocha for Rails 3.2 compatibility
   require 'mocha/setup'
   ```

## Performance Considerations

### Implementation Details

1. **Eager Loading**: Some components are eager loaded to avoid autoloading performance issues
2. **Method Caching**: Implemented for frequently called methods
3. **Memory Management**: Additional care with large data structures

## Custom Backport Components

### Implementation Details

1. **Class Loading and Resolution**:
   Adaptations to how classes and constants are loaded to work with Rails 3.2

2. **Constant Resolution**:
   Custom constant resolution logic to handle Rails 3.2 differences

3. **File System Operations**:
   Adaptations for file system operations to ensure compatibility

## Continuous Integration Adaptations

### Implementation Details

CI workflows were updated to:

1. Use Docker for consistent test environments
2. Test with Ruby 2.3.8
3. Test with Rails 3.2

## Known Implementation Tradeoffs

1. **Performance**: Some operations are slower due to polyfills and compatibility layers
2. **Memory Usage**: Higher memory usage in some cases
3. **Code Complexity**: Added complexity from compatibility layers
4. **Maintenance Burden**: Increased maintenance due to supporting older Ruby/Rails

## Future Enhancements

Planned or possible future enhancements to the backport implementation:

1. More comprehensive polyfills for missing ActiveSupport methods
2. Improved performance for the constant resolution compatibility layer
3. Better integration with classic Rails autoloading 