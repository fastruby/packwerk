# frozen_string_literal: true

require "constant_resolver"

module Packwerk
  # Holds the context of a Packwerk run across multiple files.
  class RunContext
    DEFAULT_CHECKERS = [
      ::Packwerk::ReferenceChecking::Checkers::DependencyChecker.new,
      ::Packwerk::ReferenceChecking::Checkers::PrivacyChecker.new,
    ]

    class << self
      def from_configuration(configuration)
        inflector = ActiveSupport::Inflector

        new(
          root_path: configuration.root_path,
          load_paths: configuration.load_paths,
          package_paths: configuration.package_paths,
          inflector: inflector,
          custom_associations: configuration.custom_associations,
          cache_enabled: configuration.cache_enabled?,
          cache_directory: configuration.cache_directory,
          config_path: configuration.config_path,
        )
      end
    end

    def initialize(
      root_path:,
      load_paths:,
      inflector:,
      cache_directory:,
      config_path: nil,
      package_paths: nil,
      custom_associations: [],
      checkers: DEFAULT_CHECKERS,
      cache_enabled: false
    )
      @root_path = root_path
      @load_paths = load_paths
      @package_paths = package_paths
      @inflector = inflector
      @custom_associations = custom_associations
      @checkers = checkers
      @cache_enabled = cache_enabled
      @cache_directory = cache_directory
      @config_path = config_path

      @file_processor = nil
      @context_provider = nil
      # We need to initialize this before we fork the process, see https://github.com/Shopify/packwerk/issues/182
      @cache = Cache.new(enable_cache: @cache_enabled, cache_directory: @cache_directory, config_path: @config_path)
    end

    def process_file(absolute_file:)
      unresolved_references_and_offenses = file_processor.call(absolute_file)
      references_and_offenses = ReferenceExtractor.get_fully_qualified_references_and_offenses_from(
        unresolved_references_and_offenses,
        context_provider
      )
      reference_checker = ReferenceChecking::ReferenceChecker.new(@checkers)
      references_and_offenses.flat_map { |reference| reference_checker.call(reference) }
    end

    private

    def file_processor
      @file_processor ||= FileProcessor.new(node_processor_factory: node_processor_factory, cache: @cache)
    end

    def node_processor_factory
      NodeProcessorFactory.new(
        context_provider: context_provider,
        root_path: @root_path,
        constant_name_inspectors: constant_name_inspectors
      )
    end

    def context_provider
      @context_provider ||= ::Packwerk::ConstantDiscovery.new(
        constant_resolver: resolver,
        packages: package_set
      )
    end

    def resolver
      ConstantResolver.new(
        root_path: @root_path,
        load_paths: @load_paths,
        inflector: @inflector,
      )
    end

    def package_set
      ::Packwerk::PackageSet.load_all_from(@root_path, package_pathspec: @package_paths)
    end

    def constant_name_inspectors
      [
        ::Packwerk::ConstNodeInspector.new,
        ::Packwerk::AssociationInspector.new(inflector: @inflector, custom_associations: @custom_associations),
      ]
    end
  end
end
