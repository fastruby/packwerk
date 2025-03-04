# typed: true
# frozen_string_literal: true

require "singleton"

module Packwerk
  module Parsers
    class Factory
      extend T::Sig
      include Singleton

      RUBY_REGEX = %r{
        # Although not important for regex, these are ordered from most likely to match to least likely.
        \.(rb|rake|builder|gemspec|ru)\Z
        |
        (Gemfile|Rakefile)\Z
      }x
      private_constant :RUBY_REGEX

      ERB_REGEX = /\.erb\Z/
      private_constant :ERB_REGEX

      sig { params(path: String).returns(T.nilable(ParserInterface)) }
      def for_path(path)
        case path
        when RUBY_REGEX
          @ruby_parser ||= Ruby.new
        when ERB_REGEX
          # Always return an ERB parser even if better_html is not available
          # Our mock implementation will handle the case where better_html is missing
          @erb_parser ||= erb_parser_class.new
        end
      end

      def erb_parser_class
        @erb_parser_class ||= Erb
      end

      def erb_parser_class=(klass)
        @erb_parser_class = klass
        @erb_parser = nil
      end

      def erb_parser_available?
        erb_parser_class.available?
      rescue NoMethodError
        # If erb_parser_class doesn't respond to available?, assume it's available
        true
      end
    end
  end
end
