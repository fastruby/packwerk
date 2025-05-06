
# frozen_string_literal: true

module Packwerk
  module ReferenceChecking
    module Checkers
      # Checks whether a given reference conforms to the configured graph of dependencies.
      class DependencyChecker
        
        include Checker


        def violation_type
          ViolationType::Dependency
        end

        def invalid_reference?(reference)
          return false unless reference.source_package
          return false unless reference.source_package.enforce_dependencies?
          return false if reference.source_package.dependency?(reference.constant.package)
          true
        end
      end
    end
  end
end
