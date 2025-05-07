
# frozen_string_literal: true

module Packwerk
  module ReferenceChecking
    module Checkers
      # Checks whether a given reference references a private constant of another package.
      class PrivacyChecker
        include Checker

        def violation_type
          ViolationType::Privacy
        end

        def invalid_reference?(reference)
          return false if reference.constant.public?

          privacy_option = reference.constant.package.enforce_privacy
          return false if enforcement_disabled?(privacy_option)

          return false unless privacy_option == true ||
            explicitly_private_constant?(reference.constant, explicitly_private_constants: privacy_option)

          true
        end

        private

        def explicitly_private_constant?(constant, explicitly_private_constants:)
          explicitly_private_constants.include?(constant.name) ||
            # nested constants
            explicitly_private_constants.any? { |epc| constant.name.start_with?(epc + "::") }
        end

        def enforcement_disabled?(privacy_option)
          [false, nil].include?(privacy_option)
        end
      end
    end
  end
end
