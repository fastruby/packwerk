
# frozen_string_literal: true

require "ast"

module Packwerk
  # An interface describing an object that can extract a constant name from an AST node.
  module ConstantNameInspector
    
    extend T::Helpers

    interface!

    def constant_name_from_node(node, ancestors:); end
  end
end
