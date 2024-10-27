# frozen_string_literal: true

# rbs_inline: enabled

require "prism"

require "rbmk/node"

module Rbmk
  # The class of transpiler.
  class Transpiler
    # @rbs @parse_result: Prism::ParseResult
    # @rbs @node: Rbmk::Node
    # @rbs @reverse_index_offsets: [[Integer, Integer]]
    # @rbs @rbm_script: String
    # @rbs @parse_errors: Array[Prism::ParseError]

    # @rbs src: String
    # @rbs return: void
    def initialize(src)
      @parse_result = Prism.parse(src)
      @node = Node.new(@parse_result.value)
      @parse_errors = @parse_result.errors
      @reverse_index_offsets = []
    end

    # @rbs return: String
    def transpile
      @rbm_script = @parse_result.source.source.dup
      transpile_ivar_args
    end

    # @rbs return: String
    def transpile_ivar_args
      changing_def_nodes = {}
      @parse_errors.each do |parse_error|
        case parse_error.type
        when :argument_formal_ivar
          index = index(parse_error.location.start_offset)
          length = parse_error.location.length
          raise Rbmk::Error, "Expected ivar but '#{@rbm_script[index, length]}'" if @rbm_script[index] != "@"

          dst = @rbm_script[index + 1, length - 1]
          raise Rbmk::Error, "Expected String but #{dst.inspect}" unless dst

          @rbm_script[index, length] = dst
          insert_offset(index, -1)

          arg_node = @node.each.find do |node|
            next if node.prism_node.location != parse_error.location

            node.prism_node.is_a?(Prism::RequiredParameterNode)
          end
          if !arg_node || !arg_node.prism_node.is_a?(Prism::RequiredParameterNode)
            raise Rbmk::Error,
                  "Expected Prism::RequiredParameterNode but #{arg_node&.prism_node.inspect}"
          end

          name = arg_node.prism_node.name.to_s[1..]
          def_node = arg_node.ancestors.find { _1.prism_node.is_a?(Prism::DefNode) }
          changing_def_nodes[def_node] ||= []
          changing_def_nodes[def_node].push "@#{name} = #{name}"
        end
      end

      changing_def_nodes.each do |def_node, lines|
        def_body_node = def_node.prism_node.body
        if def_body_node
          indent = def_body_node.location.start_column
          index = index(def_body_node.location.start_offset - indent)
        else
          indent = def_node.prism_node.end_keyword_loc.start_column + 2
          index = index(def_node.prism_node.end_keyword_loc.start_offset - indent + 2)
        end
        lines.reverse_each do |raw_line|
          dst_line = "#{" " * indent}#{raw_line}\n"
          @rbm_script[index, 0] = dst_line
          insert_offset(index, dst_line.size)
        end
      end
      @rbm_script
    end

    # @rbs src_index: Integer
    # @rbs return: Integer
    def index(src_index)
      offset = @reverse_index_offsets.find { _1.first <= src_index }&.last || 0
      offset + src_index
    end

    # @rbs new_index: Integer
    # @rbs new_diff: Integer
    # @rbs return: void
    def insert_offset(new_index, new_diff)
      array_index = @reverse_index_offsets.find_index.with_index do |(index, _), i|
        if new_index < index
          @reverse_index_offsets[i][1] += new_diff
          false
        else
          true
        end
      end
      if array_index
        @reverse_index_offsets[array_index, 0] = [[new_index, new_diff + @reverse_index_offsets[array_index][1]]]
      else
        @reverse_index_offsets.push [new_index, new_diff]
      end
    end
  end
end
