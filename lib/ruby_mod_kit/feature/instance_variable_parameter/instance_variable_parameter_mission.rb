# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  class Feature
    class InstanceVariableParameter
      # The mission for instance variable arguments
      class InstanceVariableParameterMission < Mission
        # @rbs generation: Generation
        # @rbs return: bool
        # @param generation [Generation]
        # @return [Boolean]
        def perform(generation)
          generation.memo_pad.each_parameter_memo do |parameter_memo|
            next unless parameter_memo.ivar_parameter

            offset = parameter_memo.offset
            parameter_node = generation.root_node.parameter_node_at(offset)
            raise RubyModKit::Error unless parameter_node

            def_node = generation.root_node.def_node_at(offset)
            raise RubyModKit::Error, "DefNode not found" unless def_node

            def_body_location = def_node.body_location
            end_loc = def_node.end_keyword_loc
            if def_body_location
              indent = def_body_location.start_column
              src_offset = def_body_location.start_offset - indent
            elsif end_loc
              indent = end_loc.start_column + 2
              src_offset = end_loc.start_offset - indent + 2
            end
            raise RubyModKit::Error if !src_offset || !indent

            name = parameter_node.name
            generation[src_offset, 0] = "#{" " * indent}@#{name} = #{name}\n"
          end
          true
        end
      end
    end
  end
end
