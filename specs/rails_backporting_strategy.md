# Rails Backporting Strategy

## Overview

This document outlines the strategy and approach for backporting Packwerk from Rails 5.x to Rails 3.2. This is part of a larger backporting effort that has already included backporting from Rails 7 alpha to Rails 5.x.

## Backporting Approach

The backporting strategy follows these key principles:

1. **Incremental Changes**: Make targeted changes to support Rails 3.2 APIs while maintaining as much of the original codebase structure as possible.
2. **Dependency Management**: Carefully manage gem dependencies to ensure compatibility with Rails 3.2.
3. **Polyfill Missing Features**: Use polyfills and shims for features that exist in Rails 5 but not in Rails 3.2.
4. **Minimal Code Divergence**: Minimize divergence from the original codebase to facilitate future updates.

## Key Rails API Differences

The following Rails API differences need to be addressed during backporting:

### ActiveSupport Changes

1. **Module#delegate**: Changes in the delegation API and error handling.
2. **ActiveSupport::Concern**: Potential differences in module inclusion behavior.
3. **String methods**: Methods like `strip_heredoc` may need replacements or polyfills.
4. **Hash methods**: Methods like `.compact`, `.deep_transform_keys` might be missing.
5. **Array methods**: Certain enumerable methods might have different behavior.

### Autoloading Considerations

While the Packwerk README mentions "Packwerk needs Zeitwerk enabled, which comes with Rails 6," our version (2.1.1) has already been backported from Rails 7 to Rails 5, suggesting autoloading may have been addressed. Our strategy involves:

1. **Analyze current autoloading approach**: Determine how the current version handles class loading
2. **Identify Rails 3.2 autoloading differences**: Understand how Rails 3.2's autoloading behaves differently
3. **Adapt as needed**: Modify code to work with Rails 3.2's autoloading conventions

### File Structure and Constants

1. Consider implications for the constant autoloading paths
2. Address differences in how Rails 3.2 resolves constants

## Tools and Libraries

We will leverage the following tools to assist with backporting:

1. **Ruby Next**: For transpiling newer Ruby syntax
2. **Backports**: To bring newer Ruby standard library features to older versions
3. **Rails Backport Gems**: Community gems that backport Rails 5 features to Rails 3.2

## Testing Strategy

To ensure backporting doesn't break functionality:

1. Maintain a comprehensive test suite
2. Run tests against both Rails 5.x and Rails 3.2 environments
3. Add specific tests for areas most affected by backporting

## Implementation Phases

The backporting process will follow these phases:

1. **Assessment**: Identify all Rails 5 specific APIs used in Packwerk
2. **Environment Setup**: Create a Rails 3.2 compatible development environment
3. **Core Functionality**: Backport core functionality first
4. **Extended Features**: Address extended features after core is working
5. **Test & Validation**: Comprehensive testing of the backported codebase

## Known Limitations

Some features may not be possible to backport completely due to fundamental differences in Rails 3.2:

1. Some advanced constant resolution features may need simplification
2. Performance in development mode may be different due to autoloading differences
3. Edge cases in constant resolution might behave differently 