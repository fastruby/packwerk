# typed: strict
# frozen_string_literal: true

# Explicitly require Mocha::API for Mocha 2.x compatibility
require "mocha/api"

module TypedMock
  extend T::Sig
  include(::Mocha::API)

  sig { params(params: T.untyped).returns(T.untyped) }
  def typed_mock(**params)
    m = mock(params)
    m.stubs(:is_a?).returns(true)
    m
  end
end
