# typed: strict
# frozen_string_literal: true

module Packwerk
  module Parsers
    module ParserInterface
      extend T::Helpers
      

      interface!


      def call(io:, file_path:)
      end
    end
  end
end
