# typed: true
# frozen_string_literal: true

require 'pathname'

ENV["RAILS_ENV"] = "test"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
ROOT = Pathname.new(__dir__).join("..").expand_path

# Load packwerk with all backports
require "packwerk"

unless Binding.method_defined?(:irb)
  require 'irb'

  class Binding
    def irb
      IRB.setup(eval("__FILE__"))#, argv: [])
      workspace = IRB::WorkSpace.new(self)

      # Handle different IRB versions
      if IRB.respond_to?(:create_irb)
        irb = IRB.create_irb(workspace)
        irb.context.main = self
      else
        irb = IRB::Irb.new(workspace)
      end

      IRB.conf[:MAIN_CONTEXT] = irb.context
      irb.eval_input
    end
  end
end


# Test frameworks - order matters
require "test/unit"
require "minitest/autorun"
require "minitest/focus"
require "mocha/test_unit"

require "support/application_fixture_helper"
require "support/factory_helper"
require "support/rails_application_fixture_helper"
require "support/rails_paths"
require "support/test_macro"
require "support/test_assertions"
require "support/yaml_file"
require "support/typed_mock"

Minitest::Test.extend(TestMacro)
Minitest::Test.include(TestAssertions)

Mocha.configure do |c|
  c.stubbing_non_existent_method = :prevent
end
