# frozen_string_literal: true

require "backports/2.4.0/regexp/match"
require "json"
require "digest"

module Packwerk
  class Cache
    class CacheContents
      attr_reader :file_contents_digest, :unresolved_references

      def initialize(file_contents_digest:, unresolved_references:)
        @file_contents_digest = file_contents_digest
        @unresolved_references = unresolved_references
      end

      def serialize
        JSON.generate({
          file_contents_digest: file_contents_digest,
          unresolved_references: unresolved_references.map do |ref|
            {
              constant_name: ref.constant_name,
              namespace_path: ref.namespace_path,
              relative_path: ref.relative_path,
              source_location: {
                line: ref.source_location.line,
                column: ref.source_location.column,
              },
            }
          end,
        })
      end

      def self.deserialize(serialized_cache_contents)
        cache_contents_json = JSON.parse(serialized_cache_contents)
        unresolved_references = cache_contents_json["unresolved_references"].map do |json|
          UnresolvedReference.new(
            json["constant_name"],
            json["namespace_path"],
            json["relative_path"],
            Node::Location.new(json["source_location"]["line"], json["source_location"]["column"],)
          )
        end

        CacheContents.new(
          file_contents_digest: cache_contents_json["file_contents_digest"],
          unresolved_references: unresolved_references,
        )
      end
    end

    def initialize(enable_cache:, cache_directory:, config_path:)
      @enable_cache = enable_cache
      @cache = {}
      @files_by_digest = {}
      @config_path = config_path
      @cache_directory = cache_directory

      if @enable_cache
        create_cache_directory!
        bust_cache_if_packwerk_yml_has_changed!
        bust_cache_if_inflections_have_changed!
      end
    end

    def bust_cache!
      FileUtils.rm_rf(@cache_directory)
    end

    def with_cache(file_path, &block)
      return block.call unless @enable_cache

      cache_location = @cache_directory.join(digest_for_string(file_path))

      cache_contents = if cache_location.exist?
        CacheContents.deserialize(cache_location.read)
      end

      file_contents_digest = digest_for_file(file_path)

      if !cache_contents.nil? && cache_contents.file_contents_digest == file_contents_digest
        Debug.out("Cache hit for #{file_path}")

        cache_contents.unresolved_references
      else
        Debug.out("Cache miss for #{file_path}")

        unresolved_references = block.call

        cache_contents = CacheContents.new(
          file_contents_digest: file_contents_digest,
          unresolved_references: unresolved_references,
        )
        cache_location.write(cache_contents.serialize)

        unresolved_references
      end
    end

    def digest_for_file(file)
      digest_for_string(File.read(file))
    end

    def digest_for_string(str)
      # MD5 appears to be the fastest
      # https://gist.github.com/morimori/1330095
      Digest::MD5.hexdigest(str)
    end

    def bust_cache_if_packwerk_yml_has_changed!
      return nil if @config_path.nil?
      bust_cache_if_contents_have_changed(File.read(@config_path), :packwerk_yml)
    end

    def bust_cache_if_inflections_have_changed!
      bust_cache_if_contents_have_changed(YAML.dump(ActiveSupport::Inflector.inflections), :inflections)
    end

    def bust_cache_if_contents_have_changed(contents, contents_key)
      current_digest = digest_for_string(contents)
      cached_digest_path = @cache_directory.join(contents_key.to_s)

      if !cached_digest_path.exist?
        # In this case, we have nothing cached
        # We save the current digest. This way the next time we compare current digest to cached digest,
        # we can accurately determine if we should bust the cache
        cached_digest_path.write(current_digest)

        nil
      elsif cached_digest_path.read == current_digest
        Debug.out("#{contents_key} contents have NOT changed, preserving cache")
      else
        Debug.out("#{contents_key} contents have changed, busting cache")

        bust_cache!
        create_cache_directory!

        cached_digest_path.write(current_digest)
      end
    end

    def create_cache_directory!
      FileUtils.mkdir_p(@cache_directory)
    end
  end

  class Debug
    def self.out(out)
      if ENV["DEBUG_PACKWERK_CACHE"]
        puts(out)
      end
    end
  end

  private_constant :Debug
end
