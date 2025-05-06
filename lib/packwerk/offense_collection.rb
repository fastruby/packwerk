
# frozen_string_literal: true

module Packwerk
  class OffenseCollection

    def initialize(root_path, deprecated_references = {})
      @root_path = root_path
      @deprecated_references = T.let(deprecated_references, T::Hash[Packwerk::Package, Packwerk::DeprecatedReferences])
      @new_violations = T.let([], T::Array[Packwerk::ReferenceOffense])
      @errors = T.let([], T::Array[Packwerk::Offense])
    end


    attr_reader :new_violations


    attr_reader :errors

    def listed?(offense)
      return false unless offense.is_a?(ReferenceOffense)
      reference = offense.reference
      deprecated_references_for(reference.source_package).listed?(reference, violation_type: offense.violation_type)
    end

    def add_offense(offense)
      unless offense.is_a?(ReferenceOffense)
        @errors << offense
        return
      end
      deprecated_references = deprecated_references_for(offense.reference.source_package)
      unless deprecated_references.add_entries(offense.reference, offense.violation_type)
        new_violations << offense
      end
    end


    def stale_violations?
      @deprecated_references.values.any?(&:stale_violations?)
    end


    def dump_deprecated_references_files
      @deprecated_references.each do |_, deprecated_references_file|
        deprecated_references_file.dump
      end
    end


    def outstanding_offenses
      errors + new_violations
    end

    private


    def deprecated_references_for(package)
      @deprecated_references[package] ||= Packwerk::DeprecatedReferences.new(
        package,
        deprecated_references_file_for(package),
      )
    end


    def deprecated_references_file_for(package)
      File.join(@root_path, package.name, "deprecated_references.yml")
    end
  end
end
