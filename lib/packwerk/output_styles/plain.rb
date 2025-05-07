
# frozen_string_literal: true

module Packwerk
  module OutputStyles
    class Plain
      include OutputStyle

      def reset
        ""
      end

      def filename
        ""
      end

      def error
        ""
      end
    end
  end
end
