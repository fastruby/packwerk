# frozen_string_literal: true
# lib/packwerk/core_ext/enumerable.rb

module Packwerk
  module CoreExt
    # Backports Ruby 2.6's Enumerable#filter method to Ruby 2.3
    module EnumerableExtensions
      def filter(&block)
        select(&block)
      end
    end
  end
end

# Only patch if the filter method doesn't already exist
unless Enumerable.method_defined?(:filter)
  Enumerable.include(Packwerk::CoreExt::EnumerableExtensions)
end
