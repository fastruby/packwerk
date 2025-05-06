
# frozen_string_literal: true

module Packwerk
  module ReferenceChecking
    class ReferenceChecker
      


      def initialize(checkers)
        @checkers = checkers
      end

      def call(reference)
        return [reference] if reference.is_a?(Packwerk::Offense)

        @checkers.each_with_object([]) do |checker, violations|
          next unless checker.invalid_reference?(reference)
          offense = Packwerk::ReferenceOffense.new(
            location: reference.source_location,
            reference: reference,
            violation_type: checker.violation_type
          )
          violations << offense
        end
      end
    end
  end
end
