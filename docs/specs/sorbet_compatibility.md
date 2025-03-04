# Sorbet Compatibility

## Overview

This document outlines the approach to handling Sorbet compatibility in the backported Packwerk project. As part of the backporting process from Rails 5 to Rails 3.2 and Ruby 3 to Ruby 2.3.8, several Sorbet-related components had to be modified or disabled while maintaining essential functionality.

## Sorbet in Packwerk

Packwerk originally used Sorbet for two main purposes:

1. **Static Type Checking**: During development to validate type correctness
2. **Runtime Type Checking**: Using `sorbet-runtime` to validate types at runtime

In the backported version:

1. **Static Type Checking**: Mostly disabled due to Ruby 2.3.8 compatibility issues
2. **Runtime Type Checking**: Maintained where possible with a compatible `sorbet-runtime` version

## Sorbet-Related Changes

### Gemfile Modifications

The following changes were made to the Gemfile:

```ruby
# Original
gem "sorbet-runtime"
gem "sorbet", group: :development
gem "tapioca", require: false

# Backported
gem "sorbet-runtime", "0.5.10461" # Specific version that works with Ruby 2.3.8
# gem "sorbet", group: :development # Commented out due to Ruby 2.3.8 incompatibility
# gem "tapioca", require: false # Commented out due to Ruby 2.3.8 incompatibility
```

### Type Signatures

Type signatures in the code have been handled using one of these approaches:

1. **Commented Out**: Some type signatures have been commented out where they caused issues
2. **Modified**: Some have been simplified to work with Ruby 2.3.8
3. **Kept As-Is**: Where they work correctly with the pinned sorbet-runtime version

Example of a modified type signature:

```ruby
# Original
sig { params(graph: T::Hash[Package, T::Array[Package]]).void }
def initialize(graph)
  @graph = graph
end

# Backported
# Modified to a simpler form that still works with sorbet-runtime
sig { params(graph: T::Hash).void }
def initialize(graph)
  @graph = graph
end
```

## Type Definition Files

The `.rbi` files in the `sorbet/` directory:

1. Remain in the codebase for documentation purposes
2. Are not actively used for type checking in the backported version
3. Serve as reference for maintainers

## Runtime Type Checking

Runtime type checking through `sorbet-runtime` is:

1. Maintained where possible for critical validations
2. Disabled where it conflicts with Ruby 2.3.8
3. Pinned to version 0.5.10461 which has been tested with Ruby 2.3.8

## Handling T::Struct

Packwerk uses `T::Struct` for some data structures. In the backported version:

1. `T::Struct` usage is maintained where compatible
2. Some complex struct definitions may be simplified
3. Runtime validations still work for basic type checking

## Development Workflow Without Static Type Checking

Without Sorbet's static type checking, the development workflow now:

1. Relies more heavily on tests to catch type errors
2. Uses runtime type checking where possible
3. Requires more careful code review for type-related issues

## Adding New Code

When adding new code to the backported project:

1. **Type Annotations**: You can add simplified type annotations that work with the pinned sorbet-runtime
2. **Avoid Complex Types**: Complex type constructs may not work correctly
3. **Test Thoroughly**: Add tests that validate type behavior at runtime

Example:

```ruby
# Recommended approach for new code
sig { params(name: String, options: T::Hash).returns(T::Boolean) }
def process_something(name, options)
  # implementation
end
```

## Testing Sorbet-Related Functionality

Special considerations for testing:

1. Include tests that verify runtime type checking works correctly
2. Test both the happy path and type errors for critical interfaces
3. Verify that removed or modified type signatures don't impact functionality

## Future Considerations

As the project evolves:

1. Monitor sorbet-runtime for versions that improve Ruby 2.3.8 compatibility
2. Consider restoring more type checking if compatibility improves
3. Document type-related decisions for future maintainers

## Known Issues

| Issue | Workaround |
|-------|------------|
| Complex generic types cause runtime errors | Simplify to basic types (e.g., `T::Array[T.untyped]` instead of specific element types) |
| Shape types may not validate correctly | Use simpler type constraints or runtime validation |
| Type errors may manifest only at runtime | Add thorough tests for type-related behaviors | 