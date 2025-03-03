# typed: strict
# frozen_string_literal: true

module Packwerk
  class ViolationType
    def serialize
      "ViolationType"
    end

    class Privacy
      class << self
        def serialize
          "privacy"
        end
      end

    end

    class Dependency
      class << self
        def serialize
          "dependency"
        end
      end

    end
    # enums do
    #   Privacy = new
    #   Dependency = new
    # end
  end
end
