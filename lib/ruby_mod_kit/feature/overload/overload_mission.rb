# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class Overload
      # The mission for overload
      class OverloadMission < Mission
        # @rbs @modified: bool

        OVERLOAD_METHOD_MAP = {
          "*": "_mul",
        }.freeze #: Hash[Symbol, String]

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
          if @modified
            generation.memo_pad.overloads_memo.each_value do |overload_memo|
              overload_memo.correct_offset(generation.root_node)
              def_node = generation.root_node.def_node_at(overload_memo.offset)
              raise RubyModKit::Error unless def_node.is_a?(Node::DefNode)

              generation[def_node.end_offset, 0] = "\n" if def_node.parent.children[-1].offset > def_node.end_offset
            end
            return true
          end

          method_memo_groups = generation.memo_pad.methods_memo.each_value.group_by do |method_memo|
            [generation.root_node.def_parent_node_at(method_memo.offset), method_memo.name]
          end
          method_memo_groups.each_value do |method_memos|
            next if method_memos.length <= 1

            @modified = true
            first_method_memo = method_memos.first
            name = first_method_memo.name
            first_def_node = generation.root_node.def_node_at(first_method_memo.offset)
            raise RubyModKit::Error unless first_def_node.is_a?(Node::DefNode)
            raise RubyModKit::Error unless name.is_a?(Symbol)

            indent = generation.line_indent(first_def_node)
            src_offset = generation.line_offset(first_def_node) || raise(RubyModKit::Error)
            script = +""

            overload_memo = generation.memo_pad.overload_memo(first_method_memo.offset, name)

            method_memos.each do |method_memo|
              type = method_memo.type
              type = "(#{type})" if type.include?(" ")
              overload_memo.add_overload_type(method_memo.parameters.map(&:type), type)
            end

            script << "def #{name}(*args)\n  case args\n"
            method_memos.each do |method_memo|
              def_node = generation.root_node.def_node_at(method_memo.offset)
              body_node = def_node&.body_node
              raise RubyModKit::Error unless def_node

              def_start_offset = generation.line_offset(def_node) || raise(RubyModKit::Error)
              def_end_offset = generation.end_line_offset(def_node) || raise(RubyModKit::Error)
              def_end_offset += generation[def_end_offset..][/.*\n*/]&.size || 0
              generation[def_start_offset, def_end_offset - def_start_offset] = ""
              generation.memo_pad.delete(method_memo)

              params = method_memo.parameters.map { |param| "#{param.type} => #{param.name}" }
              script << "  in [#{params.join(", ")}]\n"

              body = nil
              case body_node
              when Node::StatementsNode
                src_indent = generation.line_indent(body_node)
                body = "#{src_indent}#{body_node.slice}\n".gsub(/^#{src_indent}/, "    ")
              when Node::BeginNode
                src_indent = generation.line_indent(body_node)
                src_line_offset = generation.line_offset(body_node.children[0]) || raise(RubyModKit::Error)
                body = body_node.slice[(src_line_offset - body_node.offset)..]
                body = "#{src_indent}begin\n#{body}\n".gsub(/^#{src_indent}/, "    ")
              when nil
                body = ""
              end
              raise RubyModKit::Error unless body

              script << body
            end
            script << "  end\nend\n"

            script.gsub!(/^(?=.)/, indent)
            generation[src_offset, 0] = script
          end

          # if script has been changed, request reparsing before proceeding to the next mission
          !@modified
        end
      end
    end
  end
end
