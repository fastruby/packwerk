# typed: true
# frozen_string_literal: true

require "parser"
require "stringio"
require "ostruct"
require "backports/2.4.0/regexp/match"
require "json"
require "digest"
require "parser/source/buffer"

module Packwerk
  module Parsers
    # ERB parser for Packwerk
    # Handles parsing of ERB templates to extract Ruby code
    class Erb
      extend T::Sig
      include ParserInterface

      # Checks whether the better_html gem is available
      # When not available, a simpler mock implementation will be used
      # @return [Boolean] true if better_html is available
      def self.available?
        begin
          require "better_html"
          require "better_html/parser"
          true
        rescue LoadError
          false
        end
      end

      # Mock implementation of an ERB parser when better_html is not available
      # This implementation uses regex to extract Ruby code from ERB templates
      # Limitations:
      # - Limited handling of complex nested ERB structures
      # - Doesn't properly track exact source locations
      # - Cannot detect ERB syntax errors reliably
      # - May struggle with ERB comments or unusual tag formats
      # - Multi-line ERB tags might not be parsed correctly in all cases
      class MockParser
        # @param buffer [Parser::Source::Buffer] the source buffer containing ERB template
        # @param template_language [Symbol, nil] the template language (ignored in mock)
        def initialize(buffer, template_language: nil)
          @buffer = buffer
        end

        # Parses ERB content and creates a mock AST
        # @return [MockNode] a mock AST node representing the ERB content
        def parse
          # Create a mock AST that extracts Ruby code from ERB tags
          content = @buffer.source
          ruby_code = extract_ruby_code(content)
          
          # Create a simple AST structure that Packwerk can analyze
          if ruby_code.empty?
            # Return an empty program node if no Ruby code was found
            return MockNode.new(:program, [])
          end
          
          # Create code nodes for each extracted Ruby snippet
          code_nodes = ruby_code.map do |code|
            MockNode.new(:erb, [], code: code)
          end
          
          # Return a program node with all the code nodes as children
          MockNode.new(:program, code_nodes)
        end

        # Extract Ruby code from ERB tags using regex
        # Handles both <%= ... %> (output) and <% ... %> (control) tags
        # @param content [String] the ERB template content
        # @return [Array<String>] array of extracted Ruby code snippets
        def extract_ruby_code(content)
          # Simple regex to extract Ruby code from ERB tags (<%= ... %> and <% ... %>)
          # This is a basic implementation and won't handle all edge cases
          ruby_parts = []
          
          # Match <%=, <%, <%- tags and their closing %>
          # Known limitations:
          # - Doesn't handle nested ERB tags within strings properly
          # - May incorrectly extract code from ERB-like syntax in HTML attributes 
          # - Won't properly handle ERB within JavaScript code
          erb_pattern = /<%=?-?(.*?)-?%>/m
          
          # Extract all matches
          content.scan(erb_pattern) do |match|
            code = match[0].strip
            next if code.empty?
            # Skip ERB comments
            next if code.start_with?('#')
            ruby_parts << code
          end
          
          ruby_parts
        end
      end

      # Mock Node implementation that emulates the interface expected by Packwerk
      # This is a simplified version of the AST nodes returned by better_html
      class MockNode
        attr_reader :type, :children

        # @param type [Symbol] the node type (e.g., :program, :erb)
        # @param children [Array] child nodes
        # @param code [String, nil] the Ruby code represented by this node
        def initialize(type, children = [], code: nil)
          @type = type
          @children = children
          @code = code
        end

        # Location information for the node
        # @return [OpenStruct] a struct with expression.source to get the code
        def loc
          OpenStruct.new(expression: OpenStruct.new(source: @code))
        end
        
        # For debugging purposes
        # @return [String] a string representation of the node
        def to_s
          "MockNode(#{@type}, code: #{@code.inspect})"
        end
      end

      def initialize(parser_class: nil, ruby_parser: Ruby.new)
        if self.class.available?
          require "better_html/tree/tag"
          @parser_class = parser_class || BetterHtml::Parser
        else
          @parser_class = parser_class || MockParser
        end

        @ruby_parser = ruby_parser
      end

      def call(io:, file_path: "<unknown>")
        buffer = Parser::Source::Buffer.new(file_path)
        
        begin
          source = io.read
          # Ensure the source is valid UTF-8 to prevent encoding issues
          if !source.valid_encoding? && source.respond_to?(:force_encoding)
            source = source.dup.force_encoding(Encoding::UTF_8)
            source = source.encode(Encoding::UTF_8) unless source.valid_encoding?
          end
          buffer.source = source
          
          ast = parse_buffer(buffer, file_path: file_path)
          to_ruby_ast(ast, file_path)
        rescue ArgumentError, EncodingError => e
          # Handle encoding errors gracefully
          if self.class.available?
            message = "Error parsing #{file_path}: #{e.message}"
            $stderr.puts(message)
          end
          nil
        rescue StandardError => e
          # Log parsing errors but don't crash
          if self.class.available?
            message = "Error parsing #{file_path}: #{e.message}"
            $stderr.puts(message)
          end
          nil
        end
      end

      private

      # Parse a source buffer into an ERB AST
      # @param buffer [Parser::Source::Buffer] the source buffer
      # @param file_path [String] the path to the file
      # @return [Object] the parsed ERB AST
      def parse_buffer(buffer, file_path:)
        parser = @parser_class.new(buffer, template_language: :html)
        parser.parse
      end

      # Convert an ERB AST to a Ruby AST
      # @param erb_ast [Object] the ERB AST
      # @param file_path [String] the path to the file
      # @return [Object, nil] the Ruby AST or nil if conversion failed
      def to_ruby_ast(erb_ast, file_path)
        # Note that we're not using the source location (line/column) at the moment, but if we did
        # care about that, we'd need to tweak this to insert empty lines and spaces so that things
        # line up with the ERB file
        code_pieces = code_nodes(erb_ast).map do |node|
          node.loc.expression.source
        end

        return nil if code_pieces.empty?

        # Combine the code pieces and wrap them in a class if necessary
        combined_code = combined_code_with_wrapper(code_pieces, file_path)
        
        begin
          buffer = Parser::Source::Buffer.new(file_path)
          buffer.source = combined_code
          @ruby_parser.call(io: StringIO.new(combined_code), file_path: file_path)
        rescue StandardError => e
          # Use the mock parser's more forgiving approach when converting to Ruby AST fails
          if self.class.available?
            message = "Error converting ERB to Ruby AST in #{file_path}: #{e.message}"
            $stderr.puts(message)
          end
          nil
        end
      end

      # Combine code pieces and wrap them in a class definition if needed
      # @param code_pieces [Array<String>] the code pieces to combine
      # @param file_path [String] the path to the file
      # @return [String] the combined code with wrapper if needed
      def combined_code_with_wrapper(code_pieces, file_path)
        combined_code = code_pieces.join("\n")
        
        # If the code doesn't define a class or module, wrap it in a dummy class
        # to provide a valid Ruby context for parsing
        needs_wrapper = !combined_code.match?(/\b(?:class|module)\b/)
        if needs_wrapper
          class_name = "Packwerk#{Digest::MD5.hexdigest(file_path)}"
          combined_code = "class #{class_name}\n#{combined_code}\nend"
        end
        
        combined_code
      end

      # Extract code nodes from an ERB AST
      # @param node [Object] the ERB AST node
      # @yield [Object] yields each code node
      # @return [Enumerator, nil] an enumerator of code nodes if no block given
      def code_nodes(node)
        return enum_for(:code_nodes, node) unless block_given?

        # Handle different node types from better_html or our mock implementation
        if node.type == :program
          node.children.each do |child|
            code_nodes(child) { |code_node| yield code_node }
          end
        elsif node.type == :erb || (defined?(BetterHtml::Tree::ErbNode) && node.is_a?(BetterHtml::Tree::ErbNode))
          yield node
        elsif node.respond_to?(:children)
          node.children.each do |child|
            next unless child
            code_nodes(child) { |code_node| yield code_node }
          end
        end
      rescue StandardError => e
        # Gracefully handle unexpected node types or other errors
        # This helps ensure that parsing continues even with unusual ERB structures
        $stderr.puts("Warning: Error extracting code nodes: #{e.message}") if $VERBOSE
      end
    end
  end
end
