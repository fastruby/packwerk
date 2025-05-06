# frozen_string_literal: true

module Packwerk
  module ReferenceChecking
    module Checkers
      module Checker
        def violation_type; end

        def invalid_reference?(reference); end
      end
    end
  end
end
