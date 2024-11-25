# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      # The mission for parameter attributes
      class TypeAttrMission < Mission
        # @rbs @modified: bool

        # @rbs return: void
        def initialize
          super
          @modified = false
        end

        # @rbs generation: Generation
        # @rbs root_node: Node::ProgramNode
        # @rbs _parse_result: Prism::ParseResult
        # @rbs memo_pad: MemoPad
        # @rbs return: bool
        def perform(generation, root_node, _parse_result, memo_pad)
          return true if @modified

          memo_pad.def_parents_memo.each_value do |def_parent_memo|
            ivars_memo = def_parent_memo.ivars_memo.dup
            def_parent_node = root_node.def_parent_node_at(def_parent_memo.offset) || raise(RubyModKit::Error)
            attr_adding_line = 0

            ivars_memo.keep_if { |_, ivar_memo| ivar_memo.attr_kind }
            next if ivars_memo.empty?

            add_first_separator_line = false
            if attr_adding_line == 0
              attr_adding_line = def_parent_node.location.start_line
              prev_line = nil
              while generation.line(attr_adding_line) =~ /\A\s*#.*|\A$/
                prev_line = ::Regexp.last_match(0)
                attr_adding_line += 1
              end
              add_first_separator_line = prev_line != ""
            end
            line = generation.line(attr_adding_line) || next
            add_separator_line = line != "\n" && line !~ /\A\s*end$/
            offset = generation.src_offset(attr_adding_line) || next

            body_node = def_parent_node.body_node
            if body_node
              first_line = generation.line(body_node)
              indent = first_line[/\A\s*/] || raise(RubyModKit::Error)
            else
              def_parent_line = generation.line(def_parent_node)
              indent = "  #{def_parent_line[/\A\s*/]}"
            end

            generation[offset, 0] = "\n" if add_first_separator_line
            ivars_memo.each do |name, ivar_memo|
              generation[offset, 0] = "#{indent}#{ivar_memo.attr_kind} :#{name}\n"
            end
            @modified = true
            generation[offset, 0] = "\n" if add_separator_line
          end
          !@modified
        end
      end
    end
  end
end
