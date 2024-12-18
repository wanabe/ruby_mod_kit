# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Type
      # The mission for parameter attributes
      class TypeAttrMission < Mission
        # @rbs @modified: bool

        # @rbs return: void
        # @return [void]
        def initialize
          super
          @modified = false
        end

        # @rbs generation: Generation
        # @rbs return: bool
        # @param generation [Generation]
        # @return [Boolean]
        def perform(generation)
          return true if @modified

          generation.memo_pad.def_parents_memo.each_value do |def_parent_memo|
            attr_adding_line = 0
            ivars_memo = def_parent_memo.ivars_memo.dup
            def_parent_node = generation.root_node.def_parent_node_at(def_parent_memo.offset)
            raise(RubyModKit::Error) unless def_parent_node

            ivars_memo.keep_if { |_, ivar_memo| ivar_memo.attr_kind }
            next if ivars_memo.empty?

            if attr_adding_line == 0
              attr_adding_line = def_parent_node.location.start_line
              attr_adding_line += 1 while generation.line(attr_adding_line) =~ /\A\s*#.*|\A$/
            end
            line = generation.line(attr_adding_line) || next
            add_separator_line = line != "\n" && line !~ /\A\s*end$/
            offset = generation.line_offset(attr_adding_line) || next

            body_node = def_parent_node.body_node
            if body_node
              first_line = generation.line(body_node)
              indent = first_line[/\A\s*/] || raise(RubyModKit::Error)
            else
              def_parent_line = generation.line(def_parent_node)
              indent = "  #{def_parent_line[/\A\s*/]}"
              generation[offset, 0] = "\n"
            end

            ivars_memo.each do |name, ivar_memo|
              attr = ivar_memo.attr_kind
              attr = "#{ivar_memo.visibility} #{attr}" if ivar_memo.visibility
              generation[offset, 0] = "#{indent}#{attr} :#{name}\n"
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
