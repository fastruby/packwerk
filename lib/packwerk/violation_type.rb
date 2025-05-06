# frozen_string_literal: true

module Packwerk
  class ViolationType
    attr_reader :name

    def initialize(name)
      @name = name
    end

    Privacy = new("Privacy")
    Dependency = new("Dependency")
  end
end
