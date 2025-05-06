
# frozen_string_literal: true

require "optparse"

module Packwerk
  # A command-line interface to Packwerk.
  class Cli
    

    def initialize(
      configuration: nil,
      out: $stdout,
      err_out: $stderr,
      environment: "test",
      style: OutputStyles::Plain.new,
      offenses_formatter: nil
    )
      @out = out
      @err_out = err_out
      @environment = environment
      @style = style
      @configuration = T.let(configuration || Configuration.from_path, Configuration)
      @progress_formatter = T.let(Formatters::ProgressFormatter.new(@out, style: style), Formatters::ProgressFormatter)
      @offenses_formatter = T.let(offenses_formatter || Formatters::OffensesFormatter.new(style: @style),
        OffensesFormatter)
    end


    def run(args)
      success = execute_command(args)
      exit(success)
    end


    def execute_command(args)
      subcommand = args.shift
      case subcommand
      when "init"
        init
      when "generate_configs"
        generate_configs
      when "check"
        output_result(parse_run(args).check)
      when "detect-stale-violations"
        output_result(parse_run(args).detect_stale_violations)
      when "update-deprecations"
        output_result(parse_run(args).update_deprecations)
      when "validate"
        validate(args)
      when nil, "help"
        @err_out.puts(<<~USAGE)
          Usage: #{$PROGRAM_NAME} <subcommand>

          Subcommands:
            init - set up packwerk
            check - run all checks
            update - update deprecated references (deprecated, use update-deprecations instead)
            update-deprecations - update deprecated references
            validate - verify integrity of packwerk and package configuration
            help  - display help information about packwerk
        USAGE
        true
      else
        @err_out.puts("'#{subcommand}' is not a packwerk command. See `packwerk help`.")
        false
      end
    end

    private


    def init
      @out.puts("📦 Initializing Packwerk...")

      generate_configs
    end


    def generate_configs
      configuration_file = Packwerk::Generators::ConfigurationFile.generate(
        root: @configuration.root_path,
        out: @out
      )

      root_package = Packwerk::Generators::RootPackage.generate(root: @configuration.root_path, out: @out)

      success = configuration_file && root_package

      result = if success
        <<~EOS

          🎉 Packwerk is ready to be used. You can start defining packages and run `bin/packwerk check`.
          For more information on how to use Packwerk, see: https://github.com/Shopify/packwerk/blob/main/USAGE.md
        EOS
      else
        <<~EOS

          ⚠️  Packwerk is not ready to be used.
          Please check output and refer to https://github.com/Shopify/packwerk/blob/main/USAGE.md for more information.
        EOS
      end

      @out.puts(result)
      success
    end


    def output_result(result)
      @out.puts
      @out.puts(result.message)
      result.status
    end


    def fetch_files_to_process(relative_file_paths, ignore_nested_packages)
      absolute_files = FilesForProcessing.fetch(
        relative_file_paths: relative_file_paths,
        ignore_nested_packages: ignore_nested_packages,
        configuration: @configuration
      )
      abort("No files found or given. "\
        "Specify files or check the include and exclude glob in the config file.") if absolute_files.empty?
      absolute_files
    end


    def validate(_paths)
      @progress_formatter.started_validation do
        result = checker.check_all

        list_validation_errors(result)

        return result.ok?
      end
    end


    def checker
      Packwerk::ApplicationValidator.new(
        config_file_path: @configuration.config_path,
        configuration: @configuration,
        environment: @environment,
      )
    end


    def list_validation_errors(result)
      @out.puts
      if result.ok?
        @out.puts("Validation successful 🎉")
      else
        @out.puts("Validation failed ❗")
        @out.puts(result.error_value)
      end
    end


    def parse_run(params)
      relative_file_paths = T.let([], T::Array[String])
      ignore_nested_packages = nil

      if params.any? { |p| p.include?("--packages") }
        OptionParser.new do |parser|
          parser.on("--packages=PACKAGESLIST", Array, "package names, comma separated") do |p|
            relative_file_paths = p
          end
        end.parse!(params)
        ignore_nested_packages = true
      else
        relative_file_paths = params
        ignore_nested_packages = false
      end

      ParseRun.new(
        absolute_files: fetch_files_to_process(relative_file_paths, ignore_nested_packages),
        configuration: @configuration,
        progress_formatter: @progress_formatter,
        offenses_formatter: @offenses_formatter
      )
    end
  end
end
