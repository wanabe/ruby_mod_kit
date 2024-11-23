# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # The class of transpile node.
    class BaseNode
      # @rbs @location: Prism::Location
      # @rbs @children: Array[Node::BaseNode]
      # @rbs @ancestors: Array[Node::BaseNode]

      attr_reader :location #: Prism::Location

      # @rbs return: void
      def initialize
        @location = prism_node.location
      end

      # @rbs return: Array[Node::BaseNode]
      def children
        return @children if @children

        @children = prism_node.child_nodes.compact.map do |prism_child_node|
          Node.wrap(prism_child_node, parent: self)
        end
      end

      # @rbs return: Array[Node::BaseNode]
      def ancestors
        return @ancestors if @ancestors

        parent = @parent
        @ancestors = if parent
          [parent] + parent.ancestors
        else
          []
        end
      end

      # @rbs return: Symbol
      def name
        raise(RubyModKit::Error, "Expected ParameterNode but #{self.class}:#{prism_node.inspect}")
      end

      # @rbs offset: Integer
      # @rbs return: Node::BaseNode | nil
      def node_at(offset)
        return nil unless include?(offset)

        child = children.find { _1.include?(offset) }
        child&.node_at(offset) || self
      end

      # @rbs offset: Integer
      # @rbs return: Node::StatementsNode | nil
      def statements_node_at(offset)
        node = node_at(offset) || return
        [node, *node.ancestors].each { return _1 if _1.is_a?(Node::StatementsNode) }
        nil
      end

      # @rbs offset: Integer
      # @rbs return: Node::DefNode | nil
      def def_node_at(offset)
        node = node_at(offset) || return
        [node, *node.ancestors].each { return _1 if _1.is_a?(Node::DefNode) }
        nil
      end

      # @rbs offset: Integer
      # @rbs return: Node::ParameterNode | nil
      def parameter_node_at(offset)
        node = node_at(offset) || return
        [node, *node.ancestors].each { return _1 if _1.is_a?(Node::ParameterNode) }
        nil
      end

      # @rbs offset: Integer
      # @rbs return: Node::DefParentNode | nil
      def def_parent_node_at(offset)
        node = node_at(offset) || return
        [node, *node.ancestors].each { return _1 if _1.is_a?(Node::DefParentNode) }
        nil
      end

      # @rbs offset: Integer
      # @rbs return: bool
      def include?(offset)
        self.offset <= offset && offset <= prism_node.location.end_offset
      end

      # @rbs return: Prism::Node & Prism::_Node
      def prism_node
        raise RubyModKit::Error
      end

      # @rbs return: Integer
      def offset
        location.start_offset
      end

      # @rbs return: String
      def inspect
        str = +"#<#{self.class} "
        first = true
        instance_variables.each do |ivar_name|
          case ivar_name
          when :@children, :@ancestors, :@parent
            next
          end

          if first
            first = false
          else
            str << ", "
          end
          str << "#{ivar_name}="
          value = instance_variable_get(ivar_name)
          str << (
            case value
            when Prism::Node
              "#<#{value.class} location=#{value.location.inspect}>"
            else
              value.inspect
            end
          )
        end
        str << ">"
        str
      end
    end
  end
end
