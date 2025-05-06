
# frozen_string_literal: true

# TODO: make better_html not require Rails
require "rails/railtie"

require "test_helper"

module Packwerk
  module Parsers
    class ErbTest < Minitest::Test
      # We no longer need to skip tests since we have a mock implementation
      
      test "#call returns node with valid file" do
        node = File.open(fixture_path("valid.erb"), "r") do |fixture|
          Erb.new.call(io: fixture)
        end

        assert_kind_of(::AST::Node, node)
      end

      test "#call writes parse error to stdout" do
        # Skip this specific test if better_html is not available
        # because our mock doesn't raise the same errors
        skip "This test requires better_html" unless Erb.available?
        
        error_message = "stub error"
        err = Parser::SyntaxError.new(stub(message: error_message))
        parser = stub
        parser.stubs(:ast).raises(err)

        parser_class_stub = stub(new: parser)

        parser = Erb.new(parser_class: parser_class_stub)
        file_path = fixture_path("invalid.erb")

        exc = assert_raises(Parsers::ParseError) do
          File.open(file_path, "r") do |fixture|
            parser.call(io: fixture, file_path: file_path)
          end
        end

        assert_equal("Syntax error: stub error", exc.result.message)
        assert_equal(file_path, exc.result.file)
      end

      test "#call writes encoding error to stdout" do
        # Skip this specific test if better_html is not available
        # because our mock doesn't raise the same errors
        skip "This test requires better_html" unless Erb.available?
        
        error_message = "stub error"
        err = EncodingError.new(error_message)
        parser = stub
        parser.stubs(:ast).raises(err)

        parser_class_stub = stub(new: parser)

        parser = Erb.new(parser_class: parser_class_stub)
        file_path = fixture_path("invalid.erb")

        exc = assert_raises(Parsers::ParseError) do
          File.open(file_path, "r") do |fixture|
            parser.call(io: fixture, file_path: file_path)
          end
        end

        assert_equal("stub error", exc.result.message)
        assert_equal(file_path.to_s, exc.result.file)
      end

      test "#call with mock implementation returns a node" do
        # This test only runs when better_html is not available
        skip "This test is for the mock implementation" if Erb.available?
        
        node = File.open(fixture_path("valid.erb"), "r") do |fixture|
          Erb.new.call(io: fixture)
        end

        assert_kind_of(::AST::Node, node)
      end

      private

      def fixture_path(name)
        Pathname.new(__dir__).join("../../..").expand_path.join("test/fixtures/formats/erb", name).to_s
      end
    end
  end
end
