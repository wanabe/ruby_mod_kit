# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler generation.
  class Generation
    # @rbs @script: String
    # @rbs @missions: Array[Mission]
    # @rbs @memo_pad: MemoPad
    # @rbs @root_node: Node::ProgramNode
    # @rbs @offset_diff: OffsetDiff
    # @rbs @generation_num: Integer
    # @rbs @filename: String | nil
    # @rbs @corrector_manager: CorrectorManager
    # @rbs @features: Array[Feature]
    # @rbs @config: Config
    # @rbs @errors: Array[Prism::ParseError]
    # @rbs @lines: Array[String]
    # @rbs @offsets: Array[Integer]

    attr_reader :script #: String
    attr_reader :errors #: Array[Prism::ParseError]
    attr_reader :lines #: Array[String]
    attr_reader :offsets #: Array[Integer]

    # @rbs script: String
    # @rbs missions: Array[Mission]
    # @rbs memo_pad: MemoPad | nil
    # @rbs generation_num: Integer
    # @rbs config: Config | nil
    # @rbs filename: String | nil
    # @rbs corrector_manager: CorrectorManager | nil
    # @rbs features: Array[Feature] | nil
    # @rbs return: void
    def initialize(script, missions: [], memo_pad: nil, generation_num: 0, config: nil,
                   filename: nil, corrector_manager: nil, features: nil)
      @script = script
      @missions = missions
      @generation_num = generation_num
      @filename = filename
      @config = config || Config.new
      @features = features || @config.features

      @memo_pad = memo_pad || MemoPad.new
      @corrector_manager = corrector_manager || CorrectorManager.new(@features)
      @offset_diff = OffsetDiff.new
      parse_result = Prism.parse(@script)
      @errors = parse_result.errors
      @lines = parse_result.source.lines
      @offsets = parse_result.source.offsets
      @root_node = Node::ProgramNode.new(parse_result.value)
      init_missions
    end

    # @rbs return: void
    def init_missions
      return unless first_generation?

      @features.each do |feature|
        feature.create_missions.each do |mission|
          add_mission(mission)
        end
      end
    end

    # @rbs return: bool
    def first_generation?
      @generation_num == 0
    end

    # @rbs return: Generation
    def succ
      if @errors.empty?
        perform_missions
      else
        perform_corrector
      end
      @missions.each do |mission|
        mission.succ(@offset_diff)
      end
      @memo_pad.succ(@offset_diff)

      Generation.new(
        @script,
        missions: @missions,
        memo_pad: @memo_pad,
        generation_num: @generation_num + 1,
        filename: @filename,
        corrector_manager: @corrector_manager,
        features: @features,
        config: @config,
      )
    end

    # @rbs return: String
    def name
      "#{@filename || "(eval)"}[gen #{@generation_num}]"
    end

    # @rbs return: bool
    def completed?
      @errors.empty? && @missions.empty?
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

    # @rbs offset: Integer
    # @rbs return: String
    def line_by_offset(offset)
      offset = @offset_diff[offset]
      (@script.match(/.*\n?/, offset) && Regexp.last_match(0)) || raise(RubyModKit::Error)
    end

    # @rbs (Integer) -> String
    #    | (Node::BaseNode) -> String
    #    | (Prism::ParseError) -> String
    def line(*args)
      case args
      in [Integer]
        line__overload0(*args)
      in [Node::BaseNode]
        line__overload1(*args)
      in [Prism::ParseError]
        line__overload2(*args)
      end
    end

    # @rbs line_num: Integer
    # @rbs return: String
    def line__overload0(line_num)
      line_by_offset(@offsets[line_num])
    end

    # @rbs node: Node::BaseNode
    # @rbs return: String
    def line__overload1(node)
      line(node.location.start_line - 1)
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
      @offsets[line_num]
    end

    # @rbs parse_error: Prism::ParseError
    # @rbs return: Integer | nil
    def src_offset__overload1(parse_error)
      src_offset(parse_error.location.start_line - 1)
    end

    # @rbs return: void
    def perform_corrector
      @corrector_manager.perform(self, @root_node, @memo_pad)
    end

    # @rbs return: void
    def perform_missions
      @missions.delete_if do |mission|
        mission.perform(self, @root_node, @memo_pad) || break
      end
    end

    # @rbs mission: Mission
    # @rbs return: void
    def add_mission(mission)
      @missions << mission
    end

    class << self
      # @rbs src: String
      # @rbs filename: String | nil
      # @rbs config: Config | nil
      # @rbs return: Generation
      def resolve(src, filename: nil, config: nil)
        generation = Generation.new(src.dup, filename: filename, config: config)
        generation = generation.succ until generation.completed?
        generation
      end
    end
  end
end
