
# frozen_string_literal: true

require "backports/2.5.0/module/alias_method"

module TestAssertions
  def self.included(klass)
    klass.alias_method(:assert_not_nil, :refute_nil)
  end
end
