# typed: strict
# frozen_string_literal: true

module Packwerk
  module OffensesFormatter
    
    extend T::Helpers

    interface!


    def show_offenses(offenses)
    end


    def show_stale_violations(offense_collection)
    end
  end
end
