# Rails 3.2 Backport Progress

This document tracks the progress and status of backporting Packwerk to support Rails 3.2.

## Current Status

- Successfully updated dependencies in gemspec and Gemfile to work with Rails 3.2
- Implemented backports for Ruby 2.3.8 compatibility
- Fixed Factory class to handle cases where ERB parser is not available
- Fixed Rails 3.2.x specific API compatibility issues:
  - Updated `extract_application_autoload_paths` to handle different Rails versions
  - Fixed CacheContents serialization for Rails 3.2 compatibility
- Added centralized backports system for better organization

## Completed Changes

- Updated packwerk.gemspec to support Rails 3.2+
- Updated Gemfile to use Rails 3.2.22
- Added backports gem for polyfills
- Set bundler version to 1.17.3 for Ruby 2.3.8 compatibility
- Created centralized backports system in lib/packwerk/backports.rb
- Fixed ERB parser availability check
- Added backports for:
  - String#match?
  - Symbol#match?
- Fixed Factory class to handle missing ERB parser
- Fixed Rails 3.2 API compatibility issues in application_load_paths.rb
- Fixed JSON serialization issues in Cache

## ERB Parser Implementation Details

### Purpose of better_html

In the standard Packwerk implementation, the `better_html` gem provides:
1. Advanced ERB parsing capabilities for extracting Ruby code
2. Accurate source location tracking for error reporting
3. Detailed syntax analysis of ERB templates
4. Security-focused validation of ERB content

### Mock Implementation Capabilities

The mock ERB parser implemented for Rails 3.2 compatibility:
- Extracts Ruby code from ERB tags using regex patterns
- Handles standard `<%= %>` and `<% %>` tag formats
- Creates a simplified AST structure that Packwerk can analyze
- Maintains the same interface as the original implementation
- Skips ERB comments to avoid parsing non-code content

### Known Limitations

The mock implementation has the following limitations:
1. **Complex Patterns**: May not correctly handle all complex ERB structures
   - Nested ERB tags within strings
   - ERB tags embedded in HTML attributes
   - ERB within JavaScript code blocks
   
2. **Source Locations**: Cannot provide precise line and column information
   - Error messages may be less specific
   - Source mappings may be approximate
   
3. **Error Detection**: Limited ability to detect ERB syntax errors
   - Will not catch malformed ERB templates
   - Cannot validate ERB security concerns
   
4. **Multi-line Tags**: May have issues with complex multi-line ERB expressions

### Supported ERB Patterns

The mock implementation works well with:
- Basic Ruby expressions: `<%= user.name %>`
- Control flow statements: `<% if condition %>...<% end %>`
- Simple loops: `<% items.each do |item| %>...<% end %>`
- Method calls: `<%= render partial: "item", locals: { item: item } %>`

### ERB Patterns to Avoid

For best compatibility, avoid:
- Complex nested ERB with string interpolation: `<%= "#{<% if x %>...<% end %>}" %>`
- ERB tags with JavaScript manipulation: `<script><%= "var x = " + potentially_unsafe_var %></script>`
- Unusual ERB tag formats not captured by the standard regex

## Next Steps

1. Test actual usage with a Rails 3.2 application
2. Identify any additional API differences between Rails 3.2 and Rails 5.x
3. Create additional backports as needed
4. Add integration tests specific to Rails 3.2
5. Update documentation

## Rails 3.2 Specific Considerations

- Rails 3.2 has different autoloading behavior
- Some Rails APIs have changed between 3.2 and 5.x
- Ruby 2.3.8 compatibility requires backports for certain methods
- ActiveSupport functionality differences

## Known Issues

1. Some test cases are skipped when the better_html gem is not available
2. Potential differences in parallel processing in older Ruby versions may impact performance
3. Rails 3.2 apps may require additional configuration to work with packwerk 

## Debugging

When working with the ERB parser in Rails 3.2 environments:

1. Set `ENV["PACKWERK_DEBUG"]=1` to enable debug logging of parser selection
2. If encountering issues with specific ERB templates, try simplifying complex patterns
3. When available, consider adding the better_html gem to your application for improved parsing
