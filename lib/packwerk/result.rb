# typed: strict
# frozen_string_literal: true

module Packwerk
  class Result # < T::Struct
    attr_reader :status, :message

    def initialize(status, message = "")
      @status = status
      @message = message
    end
    # prop :message, String
    # prop :status, T::Boolean
  end
end
