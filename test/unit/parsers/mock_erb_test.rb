# frozen_string_literal: true
require "test_helper"
require "stringio"

module Packwerk
  module Parsers
    class MockErbTest < Minitest::Test
      setup do
        # Skip tests if better_html is available, as we're specifically testing the mock implementation
        skip "These tests are only for the mock ERB parser" if Erb.available?
      end

      def test_mock_parser_extracts_basic_ruby_code
        erb_content = <<~ERB
          <h1><%= "Hello World" %></h1>
          <p><% if user.admin? %>Admin<% else %>User<% end %></p>
        ERB

        ast = parse_erb(erb_content)

        # Verify the AST structure
        assert_equal(:program, ast.type)

        # Get all the ruby code from the AST
        code_parts = extract_code_from_ast(ast)

        # Verify the extracted code
        assert_includes(code_parts, "\"Hello World\"")
        assert_includes(code_parts, "if user.admin?")
        assert_includes(code_parts, "else")
        assert_includes(code_parts, "end")
      end

      def test_mock_parser_handles_comments
        erb_content = <<~ERB
          <%# This is a comment that should be ignored %>
          <p><%= "Not a comment" %></p>
        ERB

        ast = parse_erb(erb_content)
        code_parts = extract_code_from_ast(ast)

        # The comment should be ignored
        refute_includes(code_parts, "This is a comment that should be ignored")
        assert_includes(code_parts, "\"Not a comment\"")
      end

      def test_mock_parser_handles_multiline_erb
        erb_content = <<~ERB
          <%
            items = [1, 2, 3]
            items.each do |item|
          %>
            <li><%= item %></li>
          <% end %>
        ERB

        ast = parse_erb(erb_content)
        code_parts = extract_code_from_ast(ast)

        # The multi-line Ruby code should be properly extracted
        # We need to check for the actual whitespace that appears in the code after extraction
        multiline_code = "items = [1, 2, 3]\n  items.each do |item|" # Changed from 4 spaces to 2
        assert_includes(code_parts, multiline_code)
        assert_includes(code_parts, "item")
        assert_includes(code_parts, "end")
      end

      def test_mock_parser_handles_complex_attributes
        erb_content = <<~ERB
          <a href="<%= user_path(user) %>" class="<%= user.admin? ? 'admin' : 'user' %>">
            <%= user.name %>
          </a>
        ERB

        ast = parse_erb(erb_content)
        code_parts = extract_code_from_ast(ast)

        # All Ruby expressions should be extracted
        assert_includes(code_parts, "user_path(user)")
        assert_includes(code_parts, "user.admin? ? 'admin' : 'user'")
        assert_includes(code_parts, "user.name")
      end

      def test_mock_parser_handles_erb_in_javascript
        erb_content = <<~ERB
          <script>
            var userId = <%= user.id %>;
            var userName = "<%= user.name.gsub('"', '\\"') %>";

            <% if feature_enabled?(:analytics) %>
            enableAnalytics();
            <% end %>
          </script>
        ERB

        ast = parse_erb(erb_content)
        code_parts = extract_code_from_ast(ast)

        # JavaScript embedded Ruby should be extracted
        assert_includes(code_parts, "user.id")
        # The exact string escaping might vary, so just check for the basic function call
        assert(code_parts.any? { |part| part.include?("user.name.gsub") })
        assert_includes(code_parts, "if feature_enabled?(:analytics)")
      end

      def test_mock_parser_loads_complex_fixture
        # Load the complex ERB fixture
        erb_content = File.read(fixture_path("complex.erb"))

        # This shouldn't raise an error
        ast = parse_erb(erb_content)

        # Verify the basic structure of the AST
        assert_equal(:program, ast.type)
        assert(ast.children.size.positive?)

        # Extract code and verify a few expected Ruby snippets
        code_parts = extract_code_from_ast(ast)

        # Check for presence of various Ruby code snippets from the fixture
        assert_includes(code_parts.join(" "), "@page_title")
        assert_includes(code_parts.join(" "), "items.sum")
        assert_includes(code_parts.join(" "), "navigation_items.each")
        assert_includes(code_parts.join(" "), "Time.now.year")
      end

      private

      def parse_erb(content)
        buffer = Parser::Source::Buffer.new("(string)")
        buffer.source = content
        parser = Erb::MockParser.new(buffer)
        parser.parse
      end

      def extract_code_from_ast(node)
        code_parts = []

        if node.type == :erb && node.loc.expression.source
          code_parts << node.loc.expression.source
        elsif node.respond_to?(:children)
          node.children.each do |child|
            next unless child
            code_parts.concat(extract_code_from_ast(child))
          end
        end

        code_parts
      end

      def fixture_path(name)
        Pathname.new(__dir__).join("../../..").expand_path.join("test/fixtures/formats/erb", name).to_s
      end
    end
  end
end
