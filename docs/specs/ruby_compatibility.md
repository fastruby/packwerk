# Ruby Compatibility

## Overview

This document details the modifications and considerations necessary for ensuring Packwerk's compatibility with Ruby 2.3.8. The project has already been backported from Ruby 3 to Ruby 2.3.8 as part of the overall backporting effort.

## Ruby Version Compatibility

Packwerk was originally developed for Ruby versions ≥ 2.6 and has been backported to work with Ruby 2.3.8. This required addressing several language feature differences and syntax changes.

## Key Ruby API Differences

### Syntax Differences

1. **Pattern Matching**: Not available in Ruby 2.3.8, any usage must be refactored.
2. **Endless Methods**: Methods defined with `def method = value` must be converted to standard syntax.
3. **Safe Navigation Operator**: The safe navigation operator (`&.`) introduced in Ruby 2.3 is available but should be used cautiously.
4. **Numbered Parameters**: Block shorthand with numbered parameters (`_1`, `_2`) must be converted to explicit block parameters.
5. **Hash Syntax**: Newer hash syntax (`foo: bar`) works in 2.3, but keyword argument handling might differ.

### Standard Library Differences

1. **Missing methods**: Methods added in later Ruby versions need polyfills or alternative implementations.
2. **Enumerable Methods**: Some advanced methods on Array, Hash, and Enumerable might be missing or behave differently.
3. **Regular Expression Updates**: Regular expression features added after 2.3 need workarounds.

## Tools Used for Ruby Compatibility

### Ruby Next

[Ruby Next](https://github.com/ruby-next/ruby-next) is used to transpile newer Ruby syntax to be compatible with Ruby 2.3.8. The following configuration is used:

```ruby
# ruby-next configuration
RubyNext::Language.rewrite do
  # specify what features to transpile
  proposed false
  next_method true
  pattern_matching true
  endless_method true
  # other configuration...
end
```

### Backports

The [Backports](https://github.com/marcandre/backports) gem provides backported Ruby features for earlier Ruby versions. We use it to bring newer standard library features to Ruby 2.3.8. Examples include:

```ruby
require 'backports/2.4.0/enumerable/sum'
require 'backports/2.4.0/hash/compact'
require 'backports/2.5.0/hash/transform_keys'
# other backports as needed
```

## Implementation Approach

The implementation approach for Ruby compatibility follows these steps:

1. **Static Analysis**: Use tools like RuboCop to identify syntax not compatible with Ruby 2.3.8.
2. **Feature Detection**: Use runtime checks to detect Ruby version and load appropriate polyfills.
3. **Selective Transpilation**: Apply Ruby Next transpilation selectively to files that use incompatible syntax.
4. **Backport Loading**: Systematically require backports for needed functionality.

## Testing for Ruby Compatibility

To ensure compatibility with Ruby 2.3.8:

1. All tests run in a Ruby 2.3.8 environment via Docker
2. CI setup includes Ruby 2.3.8 testing
3. Specific tests for Ruby 2.3.8 edge cases have been added

## Known Limitations

Some features may have limitations in Ruby 2.3.8:

1. **Performance**: Some polyfilled methods may be less performant than native implementations.
2. **Regexp Engine**: The regexp engine in Ruby 2.3.8 has known limitations compared to newer versions.
3. **Exception Handling**: Some exception handling behaviors differ in Ruby 2.3.8.

## Future Considerations

As the project evolves:

1. New contributions must be checked for Ruby 2.3.8 compatibility
2. Ruby version detection may need to be expanded for selective feature loading
3. As Ruby 2.3.8 becomes less common, maintenance burden will increase 