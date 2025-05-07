
# frozen_string_literal: true

module Packwerk
  module CoreExt
    # Backports Ruby 2.4+'s Symbol#match? method to Ruby 2.3
    module SymbolExtensions
      def match?(regexp)
        to_s.match?(regexp)
      end
    end
  end
end

# Only patch if the match? method doesn't already exist
unless Symbol.method_defined?(:match?)
  Symbol.include(Packwerk::CoreExt::SymbolExtensions)
end
