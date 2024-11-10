# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpile node.
  class Node
    attr_reader :prism_node #: Prism::Node & Prism::_Node
    attr_reader :parent #: Node | nil

    # @rbs @prism_node: Prism::Node & Prism::_Node
    # @rbs @parent: Node | nil
    # @rbs @children: Array[Node]
    # @rbs @ancestors: Array[Node]

    # @rbs prism_node: Prism::Node prism_node
    # @rbs parent: Node
    # @rbs return: void
    def initialize(prism_node, parent: nil)
      @prism_node = prism_node
      @parent = parent
    end

    # @rbs return: Array[Node]
    def children
      return @children if @children

      @children = @prism_node.child_nodes.compact.map do |prism_child_node|
        Node.new(prism_child_node, parent: self)
      end
    end

    # @rbs return: Array[Node]
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
      case prism_node
      when Prism::RequiredParameterNode, Prism::OptionalKeywordParameterNode,
           Prism::OptionalParameterNode, Prism::RequiredKeywordParameterNode, Prism::DefNode
        prism_node.name
      else
        raise(RubyModKit::Error, "Expected ParameterNode but #{prism_node.inspect}")
      end
    end

    # @rbs offset: Integer
    # @rbs prism_klass: Class | nil
    # @rbs return: Node | nil
    def [](offset, prism_klass = nil)
      return nil unless include?(offset)

      child = children.find { _1.include?(offset) }
      node = child&.[](offset) || self
      return node unless prism_klass
      return node if node.prism_node.is_a?(prism_klass)

      node.ancestors.find { _1.prism_node.is_a?(prism_klass) }
    end

    # @rbs offset: Integer
    # @rbs return: bool
    def include?(offset)
      self.offset <= offset && offset <= prism_node.location.end_offset
    end

    # @rbs return: Integer
    def offset
      prism_node.location.start_offset
    end
  end
end
