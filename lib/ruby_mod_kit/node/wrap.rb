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
      # @rbs prev: Node::BaseNode | nil
      # @rbs return: Node::BaseNode
      def wrap(prism_node, parent:, prev: nil)
        case prism_node
        when Prism::BeginNode
          Node::BeginNode.new(prism_node, parent: parent, prev: prev)
        when Prism::CallNode
          Node::CallNode.new(prism_node, parent: parent, prev: prev)
        when Prism::DefNode
          Node::DefNode.new(prism_node, parent: parent, prev: prev)
        when Prism::ClassNode, Prism::ModuleNode
          Node::DefParentNode.new(prism_node, parent: parent, prev: prev)
        when Prism::RequiredParameterNode, Prism::OptionalKeywordParameterNode,
            Prism::OptionalParameterNode, Prism::RequiredKeywordParameterNode,
            Prism::RestParameterNode, Prism::BlockParameterNode
          Node::ParameterNode.new(prism_node, parent: parent, prev: prev)
        when Prism::StatementsNode
          Node::StatementsNode.new(prism_node, parent: parent, prev: prev)
        when Prism::SymbolNode
          Node::SymbolNode.new(prism_node, parent: parent, prev: prev)
        else
          Node::UntypedNode.new(prism_node, parent: parent, prev: prev)
        end
      end
    end
  end
end
