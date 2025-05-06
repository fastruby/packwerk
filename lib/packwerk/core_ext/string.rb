
# frozen_string_literal: true

module Packwerk
  module CoreExt
    # Backports Ruby 2.4+'s String#match? method to Ruby 2.3
    module StringExtensions
      def match?(pattern, pos = 0)
        # match? was added in Ruby 2.4 as a more efficient version of match
        # that doesn't create a MatchData object
        !!(self.match(pattern, pos))
      end
    end
  end
end

# Only patch if the match? method doesn't already exist
unless String.method_defined?(:match?)
  String.include(Packwerk::CoreExt::StringExtensions)
end 