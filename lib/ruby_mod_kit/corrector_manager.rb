# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # the class to manege parse error correctors
  class CorrectorManager
    # @rbs @previous_source: String
    # @rbs @correctors_error_map: Hash[Symbol, Array[Corrector]]

    # @rbs features: Array[Feature]
    # @rbs return: void
    # @param features [Array<Feature>]
    # @return [void]
    def initialize(features)
      @previous_source = +""
      @correctors_error_map = {}
      features.each do |feature|
        feature.create_correctors.each do |corrector|
          corrector.correctable_error_types.each do |error_type|
            (@correctors_error_map[error_type] ||= []) << corrector
          end
        end
      end
    end

    # @rbs generation: Generation
    # @rbs return: bool
    # @param generation [Generation]
    # @return [Boolean]
    def perform(generation)
      return true if generation.errors.empty?

      check_prev_errors(generation)
      @previous_source = generation.script.dup

      @correctors_error_map.each_value do |correctors|
        correctors.each(&:setup)
      end

      generation.errors.each do |parse_error|
        correctors = @correctors_error_map[parse_error.type] || next
        correctors.each do |corrector|
          corrector.correct(parse_error, generation)
        end
      end

      false
    end

    # @rbs generation: Generation
    # @rbs return: void
    # @param generation [Generation]
    # @return [void]
    def check_prev_errors(generation)
      return if @previous_source.empty?
      return if generation.errors.empty?
      return if @previous_source != generation.script

      message = +""
      generation.errors.each do |parse_error|
        message << "\n" unless message.empty?
        message << "#{generation.name}:#{parse_error.location.start_line}:#{parse_error.message} "
        message << "(#{parse_error.type})"
        line = generation.line(parse_error)
        if line
          message << "\n#{line.chomp}\n"
          message << "#{" " * parse_error.location.start_column}^#{"~" * [parse_error.location.length - 1, 0].max}"
        end
      end
      raise RubyModKit::SyntaxError, message
    end
  end
end
