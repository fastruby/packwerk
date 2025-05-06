
# frozen_string_literal: true

# This file centralizes all backports and polyfills needed for 
# Rails 3.2 and Ruby 2.3.8 compatibility.

module Packwerk
  module Backports
    class << self
      def apply!
        require_ruby_backports
        require_active_support_backports
        require_core_ext
      end

      private

      def require_ruby_backports
        # Ruby 2.5+ backports
        require "backports/2.5.0/kernel/yield_self"
        
        # Ruby 3.1+ backports
        require "backports/3.1"
        
        # Ruby-next for general Ruby compatibility
        require "ruby-next"
      end

      def require_active_support_backports
        # Add any ActiveSupport specific backports here
        # Example: require "active_support_backports/hash_with_indifferent_access"
      end

      def require_core_ext
        # Load all core extensions from our core_ext directory
        Dir[File.join(__dir__, "core_ext", "*.rb")].sort.each do |file|
          require file
        end
      end
    end
  end
end 