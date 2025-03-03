# typed: strict
# frozen_string_literal: true

module Packwerk
  class ViolationType
    def serialize
      "ViolationType"
    end

    class Privacy
      def serialize
        "Privacy"
      end
    end

    class Dependency
      def serialize
        "Dependency"
      end
    end
    # enums do
    #   Privacy = new
    #   Dependency = new
    # end
  end
end
