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
    # @rbs @source: String

    attr_reader :script #: String
    attr_reader :memo_pad #: MemoPad
    attr_reader :root_node #: Node::ProgramNode
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
      @source = @script.dup
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

    # @rbs src_range: Range[Integer | nil]
    # @rbs return: String
    def [](src_range)
      @source[src_range] || raise(RubyModKit::Error, "Invalid range")
    end

    # @rbs (Integer) -> String
    #    | (Node::BaseNode) -> String
    #    | (Prism::ParseError) -> String
    def line(*args)
      case args
      in [Integer => line_num]
        @lines[line_num] || raise(RubyModKit::Error)
      in [Node::BaseNode => node]
        line(node.location.start_line - 1)
      in [Prism::ParseError => parse_error]
        begin
          line(parse_error.location.start_line - 1)
        rescue RubyModKit::Error
          ""
        end
      end
    end

    # @rbs (Integer) -> (Integer | nil)
    #    | (Node::BaseNode) -> (Integer | nil)
    #    | (Node::BaseNode, Integer) -> (Integer | nil)
    #    | (Prism::ParseError) -> (Integer | nil)
    def line_offset(*args)
      case args
      in [Integer => line_num]
        @offsets[line_num]
      in [Node::BaseNode => node]
        line_offset(node, 0)
      in [Node::BaseNode => node, Integer => line_offset]
        line_offset(node.location.start_line - 1 + line_offset)
      in [Prism::ParseError => parse_error]
        line_offset(parse_error.location.start_line - 1)
      end
    end

    # @rbs node: Node::BaseNode
    # @rbs return: Integer | nil
    def end_line_offset(node)
      line_offset(node.location.end_line - 1)
    end

    # @rbs (Integer) -> String
    #    | (Node::BaseNode) -> String
    def line_indent(*args)
      case args
      in [Integer => line_num]
        line(line_num)[/\A[ \t]*/] || ""
      in [Node::BaseNode => node]
        line_indent(node.location.start_line - 1)
      end
    end

    # @rbs return: void
    def perform_corrector
      @corrector_manager.perform(self)
    end

    # @rbs return: void
    def perform_missions
      @missions.delete_if do |mission|
        mission.perform(self) || break
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
