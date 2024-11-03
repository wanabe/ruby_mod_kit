# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpiler.
  class Node
    attr_reader :prism_node #: Prism::Node & Prism::_Node
    attr_reader :parent #: Node | nil

    # @rbs @prism_node: Prism::Node & Prism::_Node
    # @rbs @parent: Node | nil

    # @rbs prism_node: Prism::Node prism_node
    # @rbs parent: Node
    # @rbs return: void
    def initialize(prism_node, parent: nil)
      @prism_node = prism_node
      @parent = parent
    end

    # @rbs location: Prism::Location
    # @rbs return: bool
    def contain?(location)
      prism_node_loc = @prism_node.location
      return false if prism_node_loc.start_offset > location.start_offset
      return false if prism_node_loc.start_offset + prism_node_loc.length < location.start_offset + location.length

      true
    end

    # @rbs @children: Array[Node]

    # @rbs return: Array[Node]
    def children
      return @children if @children

      @children = @prism_node.child_nodes.compact.map do |prism_child_node|
        Node.new(prism_child_node, parent: self)
      end
    end

    # @rbs @ancestors: Array[Node]

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

    # @rbs () -> Enumerator[Node, void]
    #    | () { (Node) -> void } -> void
    def each(&block)
      return enum_for(__method__ || :each) unless block

      yield self
      children.each do |child|
        child.each(&block)
      end
      self
    end

    # @rbs return: String
    def inspect
      @object_to_s ||= Object.instance_method(:to_s)
      @object_to_s.bind(self).call
    end

    # @rbs return: Prism::RequiredParameterNode | Prism::OptionalKeywordParameterNode
    #            | Prism::OptionalParameterNode | Prism::RequiredKeywordParameterNode
    #            | nil
    def parameter_node
      case prism_node
      when Prism::RequiredParameterNode, Prism::OptionalKeywordParameterNode,
           Prism::OptionalParameterNode, Prism::RequiredKeywordParameterNode
        prism_node
      end
    end

    # @rbs return: Prism::RequiredParameterNode | Prism::OptionalKeywordParameterNode
    #            | Prism::OptionalParameterNode | Prism::RequiredKeywordParameterNode
    def parameter_node!
      parameter_node || raise(RubyModKit::Error, "Expected ParameterNode but #{prism_node.inspect}")
    end

    # @rbs return: String
    def parameter_name
      parameter_node!.name.to_s
    end
  end
end
