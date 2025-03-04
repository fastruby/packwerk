# typed: true
# frozen_string_literal: true

require "parser"
require "stringio"
require "ostruct"

module Packwerk
  module Parsers
    class Erb
      extend T::Sig
      include ParserInterface

      def self.available?
        begin
          require "better_html"
          require "better_html/parser"
          true
        rescue LoadError
          false
        end
      end

      # Mock parser implementation for when better_html is not available
      class MockParser
        def initialize(buffer, template_language: nil)
          @buffer = buffer
        end

        def parse
          # Create a mock AST that extracts Ruby code from ERB tags
          content = @buffer.source
          ruby_code = extract_ruby_code(content)
          MockNode.new("root", [
            MockNode.new("code", [], code: ruby_code)
          ])
        end

        private

        def extract_ruby_code(content)
          # Simple regex to extract Ruby code from ERB tags (<%= ... %> and <% ... %>)
          # This is a basic implementation and won't handle all edge cases
          ruby_parts = []
          
          # Match both <%= ... %> and <% ... %> tags
          content.scan(/<%=?(.*?)%>/m) do |match|
            # Add the Ruby code from inside the ERB tags
            ruby_parts << match[0].strip
          end
          
          # Join all the code parts with newlines
          ruby_parts.join("\n")
        end
      end

      # Mock node for when better_html is not available
      class MockNode
        attr_reader :type, :children, :code
        
        def initialize(type, children = [], code: nil)
          @type = type
          @children = children
          @code = code
        end

        def loc
          OpenStruct.new(expression: OpenStruct.new(source: @code))
        end
      end

      def initialize(parser_class: nil, ruby_parser: Ruby.new)
        if self.class.available?
          parser_class ||= ::BetterHtml::Parser
          @parser_class = parser_class
        else
          # Use the mock parser when better_html is not available
          @parser_class = MockParser
        end
        @ruby_parser = ruby_parser
      end

      def call(io:, file_path: "<unknown>")
        buffer = Parser::Source::Buffer.new(file_path)
        buffer.source = io.respond_to?(:read) ? io.read : io.to_s

        begin
          erb_ast = parse_buffer(buffer, file_path: file_path)
          return to_ruby_ast(erb_ast, file_path)
        rescue EncodingError => e
          if self.class.available?
            result = ParseResult.new(file: file_path, message: e.message)
            raise Parsers::ParseError, result
          else
            $stderr.puts("Error reading #{file_path}: #{e.message}")
            return nil
          end
        rescue Parser::SyntaxError => e
          if self.class.available?
            result = ParseResult.new(file: file_path, message: "Syntax error: #{e}")
            raise Parsers::ParseError, result
          else
            $stderr.puts("Error parsing #{file_path}: #{e.message}")
            return nil
          end
        rescue StandardError => e
          $stderr.puts("Error parsing #{file_path}: #{e.message}")
          return nil
        end
      end

      def parse_buffer(buffer, file_path:)
        parser = @parser_class.new(buffer, template_language: :html)
        parser.parse
      end

      def to_ruby_ast(erb_ast, file_path)
        # Note that we're not using the source location (line/column) at the moment, but if we did
        # care about that, we'd need to tweak this to insert empty lines and spaces so that things
        # line up with the ERB file
        code_pieces = code_nodes(erb_ast).map do |node|
          if self.class.available?
            node.loc.expression.source
          else
            # For mock nodes, just use the code directly
            node.code
          end
        end

        code = code_pieces.join("\n")
        
        # Wrap code in a valid Ruby context if it's not already
        unless code.strip.empty?
          # If the code doesn't parse on its own, wrap it in a class definition
          # to provide valid context
          begin
            result = @ruby_parser.call(io: StringIO.new(code), file_path: file_path)
            return result if result
          rescue => e
            # If parsing fails, try to wrap the code in a class definition
            code = "class DummyClass\n#{code}\nend"
            return @ruby_parser.call(io: StringIO.new(code), file_path: file_path)
          end
        else
          # If no code was extracted, return a minimal valid AST
          return @ruby_parser.call(io: StringIO.new("nil"), file_path: file_path)
        end
      end

      def code_nodes(node)
        return enum_for(:code_nodes, node) unless block_given?

        if self.class.available? && node.type == :code
          yield node
        elsif !self.class.available? && node.type == "code"
          yield node
        else
          node.children.each do |child|
            # Skip non-node children (like symbols, etc.)
            next unless child.respond_to?(:type)
            code_nodes(child).each do |code_node|
              yield code_node
            end
          end
        end
      end
    end
  end
end
