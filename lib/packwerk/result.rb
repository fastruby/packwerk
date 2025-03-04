# typed: strict
# frozen_string_literal: true

unless Symbol.method_defined? :match?
  class Symbol
    def match?(*args)
      !match(*args).nil?
    end
  end
end

module Packwerk
  class Result < T::Struct
    const :message, String
    const :status, T::Boolean
  end
end
