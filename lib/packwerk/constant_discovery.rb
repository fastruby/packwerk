# typed: true
# frozen_string_literal: true

require "backports/2.5.0/string/delete_suffix"

require "constant_resolver"

module Packwerk
  # Get information about unresolved constants without loading the application code.
  # Information gathered: Fully qualified name, path to file containing the definition, package,
  # and visibility (public/private to the package).
  #
  # The implementation makes a few assumptions about the code base:
  # - `Something::SomeOtherThing` is defined in a path of either `something/some_other_thing.rb` or `something.rb`,
  #   relative to the load path. Rails' `zeitwerk` autoloader makes the same assumption.
  # - It is OK to not always infer the exact file defining the constant. For example, when a constant is inherited, we
  #   have no way of inferring the file it is defined in. You could argue though that inheritance means that another
  #   constant with the same name exists in the inheriting class, and this view is sufficient for all our use cases.
  class ConstantDiscovery
    extend T::Sig

    ConstantContext = Struct.new(:name, :location, :package, :public?)

    # @param constant_resolver [ConstantResolver]
    # @param packages [Packwerk::PackageSet]
    sig do
      params(constant_resolver: ConstantResolver, packages: Packwerk::PackageSet).void
    end
    def initialize(constant_resolver:, packages:)
      @packages = packages
      @resolver = constant_resolver
    end

    # Get the package that owns a given file path.
    #
    # @param path [String] the file path
    #
    # @return [Packwerk::Package] the package that contains the given file,
    #   or nil if the path is not owned by any component
    sig do
      params(
        path: String,
      ).returns(Packwerk::Package)
    end
    def package_from_path(path)
      @packages.package_from_path(path)
    end

    # Analyze a constant via its name.
    # If the constant is unresolved, we need the current namespace path to correctly infer its full name
    #
    # @param const_name [String] The unresolved constant's name.
    # @param current_namespace_path [Array<String>] (optional) The namespace of the context in which the constant is
    #   used, e.g. ["Apps", "Models"] for `Apps::Models`. Defaults to [] which means top level.
    # @return [Packwerk::ConstantDiscovery::ConstantContext]
    sig do
      params(
        const_name: String,
        current_namespace_path: T.nilable(T::Array[String]),
      ).returns(T.nilable(ConstantDiscovery::ConstantContext))
    end
    def context_for(const_name, current_namespace_path: [])
      begin
        constant = @resolver.resolve(const_name, current_namespace_path: current_namespace_path)
      rescue ConstantResolver::Error => e
        # Handle constant resolution errors according to todo configuration
        if ENV["PACKWERK_CONSTANT_DISCOVERY_TODO_FILE"].nil?
          # No todo file configured, raise the error
          raise(ConstantResolver::Error, e.message)
        else # The todo file is configured
          file_path = ENV.fetch("PACKWERK_CONSTANT_DISCOVERY_TODO_FILE")
          
          if File.exist?(file_path)
            # Check if the error is already in the todo
            current_content = File.read(file_path)
            if current_content.include?(e.message)
              # Error already in todo, continue silently
            else
              # Error not in todo, raise with instructions
              raise(ConstantResolver::Error, "#{e.message}\n\nThis error is not in the todo file '#{file_path}'. " \
                "Either remove the todo file to regenerate it, or manually add this error to the file.")
            end
          else
            # The todo file doesn't exist but env var is set, create and append error
            File.write(file_path, e.message)
          end
        end
        
        return nil
      end

      return unless constant

      package = @packages.package_from_path(constant.location)
      ConstantContext.new(
        constant.name,
        constant.location,
        package,
        package.public_path?(constant.location),
      )
    end
  end
end
