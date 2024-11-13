# frozen_string_literal: true

# rbs_inline: enabled

module RubyModKit
  # The class of transpile node.
  class Node
    attr_reader :parent #: Node | nil

    # @rbs @parent: Node | nil
    # @rbs @children: Array[Node]
    # @rbs @ancestors: Array[Node]

    # @rbs return: Array[Node]
    def children
      return @children if @children

      @children = prism_node.child_nodes.compact.map do |prism_child_node|
        wrap(prism_child_node)
      end
    end

    # @rbs prism_node: Prism::Node
    # @rbs return: Node
    def wrap(prism_node)
      case prism_node
      when Prism::ClassNode
        Node::ClassNode.new(prism_node, parent: self)
      when Prism::ModuleNode
        Node::ModuleNode.new(prism_node, parent: self)
      when Prism::DefNode
        Node::DefNode.new(prism_node, parent: self)
      when Prism::RequiredParameterNode, Prism::OptionalKeywordParameterNode,
           Prism::OptionalParameterNode, Prism::RequiredKeywordParameterNode
        Node::ParameterNode.new(prism_node, parent: self)
      when Prism::StatementsNode
        Node::StatementsNode.new(prism_node, parent: self)
      else
        Node::UntypedNode.new(prism_node, parent: self)
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
      raise(RubyModKit::Error, "Expected ParameterNode but #{self.class}:#{prism_node.inspect}")
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
    # @rbs return: Node | nil
    def node_at(offset)
      return nil unless include?(offset)

      child = children.find { _1.include?(offset) }
      child&.[](offset) || self
    end

    # @rbs offset: Integer
    # @rbs return: Node::StatementsNode | nil
    def statements_node_at(offset)
      node = node_at(offset)
      return node unless node
      return node if node.is_a?(Node::StatementsNode)

      node.ancestors.each do |ancestor|
        return ancestor if ancestor.is_a?(Node::StatementsNode)
      end
      nil
    end

    # @rbs offset: Integer
    # @rbs return: Node::DefNode | nil
    def def_node_at(offset)
      node = node_at(offset)
      return node unless node
      return node if node.is_a?(Node::DefNode)

      node.ancestors.each do |ancestor|
        return ancestor if ancestor.is_a?(Node::DefNode)
      end
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
      prism_node.location.start_offset
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

require_relative "node/class_node"
require_relative "node/def_node"
require_relative "node/module_node"
require_relative "node/parameter_node"
require_relative "node/program_node"
require_relative "node/statements_node"
require_relative "node/untyped_node"
