# frozen_string_literal: true

require "ast/node"

module Packwerk
  class FileProcessor
    class UnknownFileTypeResult < Offense
      def initialize(file:)
        super(file: file, message: "unknown file type")
      end
    end

    def initialize(node_processor_factory:, cache:, parser_factory: nil)
      @node_processor_factory = node_processor_factory
      @cache = cache
      @parser_factory = parser_factory || Packwerk::Parsers::Factory.instance
    end

    def call(absolute_file)
      parser = parser_for(absolute_file)
      return [UnknownFileTypeResult.new(file: absolute_file)] if parser.nil?

      @cache.with_cache(absolute_file) do
        node = parse_into_ast(absolute_file, parser)
        return [] unless node

        references_from_ast(node, absolute_file)
      end
    rescue Parsers::ParseError => e
      [e.result]
    end

    private

    def references_from_ast(node, absolute_file)
      references = []

      node_processor = @node_processor_factory.for(absolute_file: absolute_file, node: node)
      node_visitor = Packwerk::NodeVisitor.new(node_processor: node_processor)
      node_visitor.visit(node, ancestors: [], result: references)

      references
    end

    def parse_into_ast(absolute_file, parser)
      File.open(absolute_file, "r", nil, external_encoding: Encoding::UTF_8) do |file|
        parser.call(io: file, file_path: absolute_file)
      end
    end

    def parser_for(file_path)
      @parser_factory.for_path(file_path)
    end
  end
end
