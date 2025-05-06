
# frozen_string_literal: true

module Packwerk
  # Processes a single node in an abstract syntax tree (AST) using the provided checkers.
  class NodeProcessor

    def initialize(reference_extractor:, absolute_file:)
      @reference_extractor = reference_extractor
      @absolute_file = absolute_file
    end

    def call(node, ancestors)
      return unless Node.method_call?(node) || Node.constant?(node)
      @reference_extractor.reference_from_node(node, ancestors: ancestors, absolute_file: @absolute_file)
    end
  end
end
