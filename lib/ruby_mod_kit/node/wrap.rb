# frozen_string_literal: true

# rbs_inline: enabled

require_relative "call_node"
require_relative "def_node"
require_relative "def_parent_node"
require_relative "parameter_node"
require_relative "statements_node"
require_relative "symbol_node"
require_relative "untyped_node"

module RubyModKit
  # The namespace of transpile node.
  module Node
    class << self
      # @rbs prism_node: Prism::Node
      # @rbs parent: Node::BaseNode
      # @rbs return: Node::BaseNode
      def wrap(prism_node, parent:)
        case prism_node
        when Prism::CallNode
          Node::CallNode.new(prism_node, parent: parent)
        when Prism::DefNode
          Node::DefNode.new(prism_node, parent: parent)
        when Prism::ClassNode, Prism::ModuleNode
          Node::DefParentNode.new(prism_node, parent: parent)
        when Prism::RequiredParameterNode, Prism::OptionalKeywordParameterNode,
            Prism::OptionalParameterNode, Prism::RequiredKeywordParameterNode,
            Prism::RestParameterNode
          Node::ParameterNode.new(prism_node, parent: parent)
        when Prism::StatementsNode
          Node::StatementsNode.new(prism_node, parent: parent)
        when Prism::SymbolNode
          Node::SymbolNode.new(prism_node, parent: parent)
        else
          Node::UntypedNode.new(prism_node, parent: parent)
        end
      end
    end
  end
end
