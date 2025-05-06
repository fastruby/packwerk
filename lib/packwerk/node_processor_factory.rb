# frozen_string_literal: true

module Packwerk
  class NodeProcessorFactory
    attr_reader :root_path, :context_provider, :constant_name_inspectors

    def initialize(root_path:, context_provider:, constant_name_inspectors:)
      @root_path = root_path
      @context_provider = context_provider
      @constant_name_inspectors = constant_name_inspectors
    end

    def for(absolute_file:, node:)
      ::Packwerk::NodeProcessor.new(
        reference_extractor: reference_extractor(node: node),
        absolute_file: absolute_file,
      )
    end

    private

    def reference_extractor(node:)
      ::Packwerk::ReferenceExtractor.new(
        constant_name_inspectors: constant_name_inspectors,
        root_node: node,
        root_path: root_path,
      )
    end
  end
end
