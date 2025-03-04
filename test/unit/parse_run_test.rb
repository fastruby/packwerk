# frozen_string_literal: true
require "test_helper"
require "rails_test_helper"
require "byebug"

module Packwerk
  class ParseRunTest < Minitest::Test
    include FactoryHelper
    include ApplicationFixtureHelper

    setup do
      setup_application_fixture
    end

    teardown do
      teardown_application_fixture
    end

    test "#detect_stale_violations returns expected Result when stale violations present" do
      use_template(:minimal)
      OffenseCollection.any_instance.stubs(:stale_violations?).returns(true)
      RunContext.any_instance.stubs(:process_file).returns([])

      parse_run = Packwerk::ParseRun.new(
        absolute_files: ["path/of/exile.rb"],
        configuration: Configuration.from_path
      )
      result = parse_run.detect_stale_violations
      assert_equal "There were stale violations found, please run `packwerk update-deprecations`", result.message
      refute result.status
    end

    test "#update_deprecations returns success when there are no offenses" do
      use_template(:minimal)
      RunContext.any_instance.stubs(:process_file).returns([])
      
      # Track if the method was called
      method_called = false
      
      # Use the real class but stub just the method we care about
      real_instance = Packwerk::OffenseCollection.new('.')
      real_instance.stubs(:dump_deprecated_references_files).with do
        method_called = true
        true # Return value
      end
      
      # Make sure new returns our instrumented instance
      Packwerk::OffenseCollection.stubs(:new).returns(real_instance)
      
      parse_run = Packwerk::ParseRun.new(
        absolute_files: ["path/of/exile.rb"],
        configuration: Configuration.from_path
      )
      result = parse_run.update_deprecations
      
      # Verify method was called
      assert method_called, "dump_deprecated_references_files should have been called"
      
      assert_equal result.message, <<~EOS
        No offenses detected
        ✅ `deprecated_references.yml` has been updated.
      EOS
      assert result.status
    end

    test "#update_deprecations returns exit code 1 when there are offenses" do
      use_template(:minimal)
      offense = Offense.new(file: "path/of/exile.rb", message: "something")
      RunContext.any_instance.stubs(:process_file).returns([offense])
      
      # Track if the method was called
      method_called = false
      
      # Use the real class but stub just the method we care about
      real_instance = Packwerk::OffenseCollection.new(".")
      real_instance.stubs(:dump_deprecated_references_files).with do
        method_called = true
        true # Return value
      end
      
      # Make sure new returns our instrumented instance
      Packwerk::OffenseCollection.stubs(:new).returns(real_instance)

      parse_run = Packwerk::ParseRun.new(
        absolute_files: ["path/of/exile.rb"],
        configuration: Configuration.from_path
      )
      result = parse_run.update_deprecations

      # Verify method was called
      assert method_called, "dump_deprecated_references_files should have been called"

      expected = <<~EOS
        path/of/exile.rb
        something

        1 offense detected

        ✅ `deprecated_references.yml` has been updated.
      EOS
      assert_equal expected, result.message
      refute result.status
    end

    test "#check only reports error progress for unlisted violations" do
      use_template(:minimal)
      offense = ReferenceOffense.new(reference: build_reference, violation_type: ViolationType::Privacy)
      DeprecatedReferences.any_instance.stubs(:listed?).returns(true)
      out = StringIO.new
      parse_run = Packwerk::ParseRun.new(
        absolute_files: ["some/path.rb"],
        configuration: Configuration.new({ "parallel" => false }),
        progress_formatter: Packwerk::Formatters::ProgressFormatter.new(out)
      )
      RunContext.any_instance.stubs(:process_file).returns([offense])
      result = parse_run.check

      expected_output = <<~EOS
        📦 Packwerk is inspecting 1 file
        \\.
        📦 Finished in \\d+\\.\\d+ seconds
      EOS
      assert_match(/#{expected_output}/, out.string)

      assert result.status
      expected_message = <<~EOS
        No offenses detected
        No stale violations detected
      EOS
      assert_equal expected_message, result.message
    end

    test "#check result has failure status when stale violations exist" do
      use_template(:minimal)
      offense = ReferenceOffense.new(reference: build_reference, violation_type: ViolationType::Privacy)
      DeprecatedReferences.any_instance.stubs(:listed?).returns(true)
      OffenseCollection.any_instance.stubs(:stale_violations?).returns(true)
      out = StringIO.new
      parse_run = Packwerk::ParseRun.new(
        absolute_files: ["some/path.rb"],
        configuration: Configuration.new({ "parallel" => false }),
        progress_formatter: Packwerk::Formatters::ProgressFormatter.new(out)
      )
      RunContext.any_instance.stubs(:process_file).returns([offense])
      result = parse_run.check

      expected_output = <<~EOS
        📦 Packwerk is inspecting 1 file
        \\.
        📦 Finished in \\d+\\.\\d+ seconds
      EOS
      assert_match(/#{expected_output}/, out.string)

      expected_message = <<~EOS
        No offenses detected
        There were stale violations found, please run `packwerk update-deprecations`
      EOS

      refute result.status
      assert_equal expected_message, result.message
    end

    test "runs in parallel" do
      use_template(:minimal)
      offense = ReferenceOffense.new(reference: build_reference, violation_type: ViolationType::Privacy)
      offense2 = ReferenceOffense.new(
        reference: build_reference(path: "some/other_path.rb"),
        violation_type: ViolationType::Privacy
      )
      parse_run = Packwerk::ParseRun.new(
        absolute_files: ["some/path.rb", "some/other_path.rb"],
        configuration: Configuration.new
      )
      RunContext.any_instance.stubs(:process_file).returns([offense]).returns([offense2])

      result = parse_run.check
      refute result.status
      assert_match(/2 offenses detected/, result.message)
    end
  end
end
