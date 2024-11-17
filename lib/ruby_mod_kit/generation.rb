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

    attr_reader :parse_result #: Prism::ParseResult
    attr_reader :script #: String

    # @rbs script: String
    # @rbs missions: Array[Mission]
    # @rbs memo: Memo
    # @rbs generation_num: Integer
    # @rbs return: void
    def initialize(script, missions: [], memo: Memo.new, generation_num: 0)
      @script = script
      @missions = missions
      @memo = memo
      @generation_num = generation_num
      @offset_diff = OffsetDiff.new
      @parse_result = Prism.parse(@script)
      @root_node = Node::ProgramNode.new(@parse_result.value)
      init_missions
    end

    # @rbs return: void
    def init_missions
      return unless first_generation?

      add_mission(Mission::FixParseError.new)
      add_mission(Mission::TypeAttr.new)
      add_mission(Mission::Overload.new)
      add_mission(Mission::TypeParameter.new)
      add_mission(Mission::TypeReturn.new)
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
      )
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

    # @rbs (Node) -> String
    #    | (Integer) -> String
    def line(*args)
      case args
      in [Node]
        line__overload0(*args)
      in [Integer]
        line__overload1(*args)
      end
    end

    # @rbs node: Node
    # @rbs return: String
    def line__overload0(node)
      line(node.prism_node.location.start_line - 1)
    end

    # @rbs line_num: Integer
    # @rbs return: String
    def line__overload1(line_num)
      offset = @offset_diff[@parse_result.source.offsets[line_num]]
      (@script.match(/.*\n?/, offset) && Regexp.last_match(0)) || raise(RubyModKit::Error)
    end

    # @rbs line_num: Integer
    # @rbs return: Integer | nil
    def src_offset(line_num)
      parse_result.source.offsets[line_num]
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
