# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  module Node
    # The class of transpile node.
    class BaseNode
      # @rbs @location: Prism::Location
      # @rbs @children: Array[Node::BaseNode]
      # @rbs @ancestors: Array[Node::BaseNode]
      # @rbs @prev: Node::BaseNode | nil

      attr_reader :prev #: Node::BaseNode | nil

      # @rbs return: Prism::Location
      # @return [Prism::Location]
      def location
        return @location if defined?(@location)

        @location = prism_node.location
      end

      # @rbs return: Array[Node::BaseNode]
      # @return [Array<Node::BaseNode>]
      def children
        return @children if @children

        prev = nil
        @children = prism_node.child_nodes.compact.map do |prism_child_node|
          prev = wrap(prism_child_node, prev: prev)
        end
      end

      # @rbs prism_node: Prism::Node
      # @rbs prev: Node::BaseNode | nil
      # @rbs return: Node::BaseNode
      # @param prism_node [Prism::Node]
      # @param prev [Node::BaseNode, nil]
      # @return [Node::BaseNode]
      def wrap(prism_node, prev: nil)
        Node.wrap(prism_node, parent: self, prev: prev)
      end

      # @rbs return: Array[Node::BaseNode]
      # @return [Array<Node::BaseNode>]
      def ancestors
        return @ancestors if @ancestors

        parent = self.parent
        @ancestors = if parent
          [parent] + parent.ancestors
        else
          []
        end
      end

      # @rbs return: BaseNode | nil
      # @return [BaseNode, nil]
      def parent
        raise(RubyModKit::Error)
      end

      # @rbs return: Symbol
      # @return [Symbol]
      def name
        raise(RubyModKit::Error, "Expected ParameterNode but #{self.class}:#{prism_node.inspect}")
      end

      # @rbs offset: Integer
      # @rbs return: Node::BaseNode | nil
      # @param offset [Integer]
      # @return [Node::BaseNode, nil]
      def node_at(offset)
        return nil unless include?(offset)

        child = children.find { _1.include?(offset) }
        child&.node_at(offset) || self
      end

      # @rbs offset: Integer
      # @rbs return: Node::StatementsNode | nil
      # @param offset [Integer]
      # @return [Node::StatementsNode, nil]
      def statements_node_at(offset)
        node = node_at(offset) || return
        [node, *node.ancestors].each { return _1 if _1.is_a?(Node::StatementsNode) }
        nil
      end

      # @rbs offset: Integer
      # @rbs return: Node::DefNode | nil
      # @param offset [Integer]
      # @return [Node::DefNode, nil]
      def def_node_at(offset)
        node = node_at(offset) || return
        [node, *node.ancestors].each { return _1 if _1.is_a?(Node::DefNode) }
        nil
      end

      # @rbs offset: Integer
      # @rbs return: Node::ParameterNode | nil
      # @param offset [Integer]
      # @return [Node::ParameterNode, nil]
      def parameter_node_at(offset)
        node = node_at(offset) || return
        [node, *node.ancestors].each { return _1 if _1.is_a?(Node::ParameterNode) }
        nil
      end

      # @rbs offset: Integer
      # @rbs allowed: Array[Class] | nil
      # @rbs return: Node::DefParentNode | nil
      # @param offset [Integer]
      # @param allowed [Array<Class>, nil]
      # @return [Node::DefParentNode, nil]
      def def_parent_node_at(offset, allowed: nil)
        node = node_at(offset) || return
        [node, *node.ancestors].each do |ancestor_node|
          return ancestor_node if ancestor_node.is_a?(Node::DefParentNode)
          return nil if allowed && !allowed.include?(ancestor_node.class)
        end
        nil
      end

      # @rbs offset: Integer
      # @rbs return: bool
      # @param offset [Integer]
      # @return [Boolean]
      def include?(offset)
        self.offset <= offset && offset <= prism_node.location.end_offset
      end

      # @rbs return: Integer
      # @return [Integer]
      def offset
        location.start_offset
      end

      # @rbs return: Integer
      # @return [Integer]
      def end_offset
        location.end_offset
      end

      # @rbs return: String
      # @return [String]
      def slice
        location.slice
      end

      # @rbs return: String
      # @return [String]
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

      private

      # :nocov:
      # This is just for interface definition, must not be called
      # @rbs return: Prism::Node & Prism::_Node
      # @return [Prism::Node & Prism::_Node]
      def prism_node
        raise RubyModKit::Error
      end
      # :nocov:
    end
  end
end
