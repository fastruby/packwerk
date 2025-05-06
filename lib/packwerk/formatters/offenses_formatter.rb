# typed: strict
# frozen_string_literal: true

module Packwerk
  module Formatters
    class OffensesFormatter
      include Packwerk::OffensesFormatter

      


      def initialize(style: OutputStyles::Plain.new)
        @style = style
      end


      def show_offenses(offenses)
        return "No offenses detected" if offenses.empty?

        <<~EOS
          #{offenses_list(offenses)}
          #{offenses_summary(offenses)}
        EOS
      end


      def show_stale_violations(offense_collection)
        if offense_collection.stale_violations?
          "There were stale violations found, please run `packwerk update-deprecations`"
        else
          "No stale violations detected"
        end
      end

      private


      def offenses_list(offenses)
        offenses
          .compact
          .map { |offense| offense.to_s(@style) }
          .join("\n")
      end


      def offenses_summary(offenses)
        offenses_string = "offense".pluralize(offenses.length)
        "#{offenses.length} #{offenses_string} detected"
      end
    end
  end
end
