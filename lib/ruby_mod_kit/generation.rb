# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler generation.
  class Generation
    # @rbs @parse_result: Prism::ParseResult
    # @rbs @script: String
    # @rbs @missions: Array[Mission]
    # @rbs @memo: Memo
    # @rbs @root_node: Node::ProgramNode
    # @rbs @offset_diff: OffsetDiff
    # @rbs @generation_num: Integer
    # @rbs @filename: String | nil

    attr_reader :parse_result #: Prism::ParseResult
    attr_reader :script #: String

    # @rbs script: String
    # @rbs missions: Array[Mission]
    # @rbs memo: Memo
    # @rbs generation_num: Integer
    # @rbs filename: String | nil
    # @rbs return: void
    def initialize(script, missions: [], memo: Memo.new, generation_num: 0, filename: nil)
      @script = script
      @missions = missions
      @memo = memo
      @generation_num = generation_num
      @filename = filename
      @offset_diff = OffsetDiff.new
      @parse_result = Prism.parse(@script)
      @root_node = Node::ProgramNode.new(@parse_result.value)
      init_missions
    end

    # @rbs return: void
    def init_missions
      return unless first_generation?

      add_mission(Mission::FixParseErrorMission.new)
      add_mission(Mission::TypeAttrMission.new)
      add_mission(Mission::OverloadMission.new)
      add_mission(Mission::TypeParameterMission.new)
      add_mission(Mission::TypeReturnMission.new)
    end

    # @rbs return: bool
    def first_generation?
      @generation_num == 0
    end

    # @rbs return: Generation
    def succ
      @missions.each do |mission|
        mission.succ(@offset_diff)
      end
      @memo.succ(@offset_diff)
      Generation.new(
        @script,
        missions: @missions,
        memo: @memo,
        generation_num: @generation_num + 1,
        filename: @filename,
      )
    end

    # @rbs return: String
    def name
      "#{@filename || "(eval)"}[gen #{@generation_num}]"
    end

    # @rbs return: void
    def resolve
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

    # @rbs (Integer) -> String
    #    | (Node) -> String
    #    | (Prism::ParseError) -> String
    def line(*args)
      case args
      in [Integer]
        line__overload0(*args)
      in [Node]
        line__overload1(*args)
      in [Prism::ParseError]
        line__overload2(*args)
      end
    end

    # @rbs line_num: Integer
    # @rbs return: String
    def line__overload0(line_num)
      offset = @offset_diff[@parse_result.source.offsets[line_num]]
      (@script.match(/.*\n?/, offset) && Regexp.last_match(0)) || raise(RubyModKit::Error)
    end

    # @rbs node: Node
    # @rbs return: String
    def line__overload1(node)
      line(node.prism_node.location.start_line - 1)
    end

    # @rbs parse_error: Prism::ParseError
    # @rbs return: String
    def line__overload2(parse_error)
      line(parse_error.location.start_line - 1)
    end

    # @rbs (Integer) -> (Integer | nil)
    #    | (Prism::ParseError) -> (Integer | nil)
    def src_offset(*args)
      case args
      in [Integer]
        src_offset__overload0(*args)
      in [Prism::ParseError]
        src_offset__overload1(*args)
      end
    end

    # @rbs line_num: Integer
    # @rbs return: Integer | nil
    def src_offset__overload0(line_num)
      parse_result.source.offsets[line_num]
    end

    # @rbs parse_error: Prism::ParseError
    # @rbs return: Integer | nil
    def src_offset__overload1(parse_error)
      src_offset(parse_error.location.start_line - 1)
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
