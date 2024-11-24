# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # the class to manege parse error correctors
  class CorrectorManager
    # @rbs @previous_error_messages: Array[String]

    # @rbs return: void
    def initialize
      @previous_error_messages = []
      @correctors_error_map = {}
      correctors = [
        RubyModKit::Feature::InstanceVariableParameter::InstanceVariableParameterCorrector.new,
        RubyModKit::Feature::Type::InstanceVariableColonCorrector.new,
        RubyModKit::Feature::Type::ParameterArrowCorrector.new,
        RubyModKit::Feature::Type::ReturnValueColonCorrector.new,
      ]
      correctors.each do |corrector|
        corrector.correctable_error_types.each do |error_type|
          (@correctors_error_map[error_type] ||= []) << corrector
        end
      end
    end

    # @rbs generation: Generation
    # @rbs root_node: Node::ProgramNode
    # @rbs parse_result: Prism::ParseResult
    # @rbs memo_pad: MemoPad
    # @rbs return: bool
    def perform(generation, root_node, parse_result, memo_pad)
      return true if parse_result.errors.empty?

      check_prev_errors(generation, parse_result)
      @previous_error_messages = parse_result.errors.map(&:message)

      parse_result.errors.each do |parse_error|
        correctors = @correctors_error_map[parse_error.type] || next
        correctors.each do |corrector|
          corrector.correct(parse_error, generation, root_node, memo_pad)
        end
      end

      false
    end

    # @rbs generation: Generation
    # @rbs parse_result: Prism::ParseResult
    # @rbs return: void
    def check_prev_errors(generation, parse_result)
      return if @previous_error_messages.empty?
      return if parse_result.errors.empty?
      return if @previous_error_messages != parse_result.errors.map(&:message)

      message = +""
      parse_result.errors.each do |parse_error|
        message << "\n" unless message.empty?
        message << "#{generation.name}:#{parse_error.location.start_line}:#{parse_error.message} "
        message << "(#{parse_error.type})"
        line = parse_result.source.lines[parse_error.location.start_line - 1]
        if line
          message << "\n#{line.chomp}\n"
          message << "#{" " * parse_error.location.start_column}^#{"~" * [parse_error.location.length - 1, 0].max}"
        end
      end
      raise RubyModKit::SyntaxError, message
    end
  end
end
