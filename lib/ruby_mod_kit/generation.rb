# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler generation.
  class Generation
    # @rbs @missions: Array[Mission]
    # @rbs @script: String

    attr_reader :parse_result #: Prism::ParseResult
    attr_reader :script #: String

    # @rbs script: String
    # @rbs missions: Array[Mission]
    # @rbs memo: Memo
    # @rbs return: void
    def initialize(script, missions: [], memo: Memo.new)
      @script = script
      @missions = missions
      @memo = memo
      @offset_diff = OffsetDiff.new
      @parse_result = Prism.parse(@script)
      @root_node = Node::ProgramNode.new(@parse_result.value)
    end

    # @rbs return: bool
    def first_generation?
      @memo.generation_num == 0
    end

    # @rbs return: Generation
    def succ
      @missions.each do |mission|
        mission.succ(@offset_diff)
      end
      @memo.succ(@offset_diff, @parse_result.errors.map(&:message))
      Generation.new(
        @script,
        missions: @missions,
        memo: @memo,
      )
    end

    # @rbs return: void
    def resolve
      if first_generation?
        add_mission(Mission::FixParseError.new)
      elsif !@parse_result.errors.empty? && @memo.previous_error_messages == @parse_result.errors.map(&:message)
        @parse_result.errors.each do |parse_error|
          warn(
            ":#{parse_error.location.start_line}:#{parse_error.message} (#{parse_error.type})",
            @parse_result.source.lines[parse_error.location.start_line - 1],
            "#{" " * parse_error.location.start_column}^#{"~" * [parse_error.location.length - 1, 0].max}",
          )
        end
        raise RubyModKit::Error, "Syntax error"
      end

      perform_missions
    end

    # @rbs return: bool
    def completed?
      @parse_result.errors.empty? && @missions.empty?
    end

    # @rbs src_offset: Integer
    # @rbs length: Integer
    # @rbs str: String
    # @rbs return: String
    def []=(src_offset, length, str)
      diff = str.length - length
      @script[@offset_diff[src_offset], length] = str
      @offset_diff.insert(src_offset, diff)
    end

    # @rbs src_range: Range[Integer]
    # @rbs return: String
    def [](src_range)
      dst_range = Range.new(@offset_diff[src_range.first], @offset_diff[src_range.last], src_range.exclude_end?)
      @script[dst_range] || raise(RubyModKit::Error, "Invalid range")
    end

    # @rbs return: void
    def perform_missions
      @missions.delete_if do |mission|
        mission.perform(self, @root_node, @parse_result, @memo) || break
      end
    end

    # @rbs mission: Mission
    # @rbs return: void
    def add_mission(mission)
      @missions << mission
    end
  end
end
