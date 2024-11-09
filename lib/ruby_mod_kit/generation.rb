# frozen_string_literal: true

# rbs_inline: enabled

require "prism"
require "sorted_set"

require "ruby_mod_kit/memo"
require "ruby_mod_kit/node"
require "ruby_mod_kit/mission"
require "ruby_mod_kit/mission/ivar_arg"
require "ruby_mod_kit/mission/type_parameter"
require "ruby_mod_kit/mission/fix_parse_error"

module RubyModKit
  # The class of transpiler generation.
  class Generation
    # @rbs @diffs: SortedSet[[Integer, Integer, Integer]]
    # @rbs @missions: Array[Mission]
    # @rbs @script: String

    attr_reader :parse_result #: Prism::ParseResult
    attr_reader :script #: String

    # @rbs script: String
    # @rbs missions: Array[Mission]
    # @rbs previous_error_count: Integer
    # @rbs generation_num: Integer
    # @rbs memo: Memo
    # @rbs return: void
    def initialize(script, missions: [], memo: Memo.new)
      @script = script
      @missions = missions
      @memo = memo
      @diffs = SortedSet.new
      @parse_result = Prism.parse(@script)
      @root_node = Node.new(@parse_result.value)
    end

    # @rbs return: bool
    def first_generation?
      @memo.generation_num == 0
    end

    # @rbs return: Generation
    def generate_next
      @memo.previous_error_count = @parse_result.errors.size
      Generation.new(
        @script,
        missions: @missions,
        memo: @memo.succ,
      )
    end

    # @rbs return: void
    def resolve
      if first_generation?
        add_mission(Mission::FixParseError.new(0, ""))
      elsif !@parse_result.errors.empty? && @memo.previous_error_count <= @parse_result.errors.size
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
      @script[dst_offset(src_offset), length] = str
      insert_diff(src_offset, diff)
    end

    # @rbs src_range: Range[Integer]
    # @rbs return: String
    def [](src_range)
      dst_range = Range.new(dst_offset(src_range.first), dst_offset(src_range.last), src_range.exclude_end?)
      @script[dst_range] || raise(RubyModKit::Error, "Invalid range")
    end

    # @rbs return: void
    def perform_missions
      @missions.delete_if do |mission|
        mission.perform(self, @root_node, @parse_result, @memo) || break
      end
      @missions.each do |mission|
        mission.offset = dst_offset(mission.offset)
      end
    end

    # @rbs src_offset: Integer
    # @rbs return: Integer
    def dst_offset(src_offset)
      dst_offset = src_offset
      @diffs.each do |(offset, _, diff)|
        break if offset > src_offset
        break if offset == src_offset && diff < 0

        dst_offset += diff
      end
      dst_offset
    end

    # @rbs src_offset: Integer
    # @rbs new_diff: Integer
    # @rbs return: void
    def insert_diff(src_offset, new_diff)
      @diffs << [src_offset, @diffs.size, new_diff]
    end

    # @rbs mission: Mission
    # @rbs return: void
    def add_mission(mission)
      @missions << mission
    end
  end
end
