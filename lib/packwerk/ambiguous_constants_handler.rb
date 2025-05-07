
# frozen_string_literal: true

require "bundler"

module Packwerk
  # Extracts the load paths from the analyzed application so that we can map constant names to paths.
  module AmbiguousConstantsHandler
    class << self
      def call(exception)
        # Handle constant resolution errors according to todo configuration
        if ENV["PACKWERK_CONSTANT_DISCOVERY_TODO_FILE"].nil?
          # No todo file configured, raise the error
          raise exception
        else # The todo file is configured
          file_path = ENV.fetch("PACKWERK_CONSTANT_DISCOVERY_TODO_FILE")

          if File.exist?(file_path)
            # Check if the error is already in the todo
            current_content = File.read(file_path)
            if current_content.include?(exception.message)
              # Error already in todo, continue silently
            else
              # Error not in todo, raise with instructions
              raise("AmbiguousConstantsHandler: #{exception.message}\n\nThis error is not in the todo file '#{file_path}'. " \
                "Either remove the todo file to regenerate it, or manually add this error to the file.")
            end
          else
            # The todo file doesn't exist but env var is set, create and append error
            File.write(file_path, exception.message)
          end
        end
      end
    end
  end
end
