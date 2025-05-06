
# frozen_string_literal: true

module Packwerk
  module OutputStyle
    
    extend T::Helpers

    interface!


    def reset; end


    def filename; end


    def error; end
  end
end
