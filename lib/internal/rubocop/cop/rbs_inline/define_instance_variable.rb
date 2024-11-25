# frozen_string_literal: true

# rbs_inline: enabled

module RuboCop
  module Cop
    module RbsInline
      # detect undefined instance variable
      class DefineInstanceVariable < RuboCop::Cop::Base
        # @rbs @instance_variable_names_map: Hash[String, Set[Symbol]]

        MSG = "Add RBS inline annotation to instance variable"

        # @rbs node: RuboCop::AST::AsgnNode
        # @rbs return: void
        def on_ivasgn(node)
          add_offense(node) if instance_variable_missing?(node.name)
        end

        # @rbs node: RuboCop::AST::Node
        # @rbs return: void
        def on_ivar(node)
          name = node.children[0]
          return unless name.is_a?(Symbol)

          add_offense(node) if instance_variable_missing?(name)
        end

        # @rbs return: Set[Symbol]
        def instance_variable_names
          @instance_variable_names_map ||= {}
          file_content = @instance_variable_names_map[processed_source.file_path]
          return file_content if file_content

          file_content = Set.new
          File.read(processed_source.file_path).scan(/^\s*# @rbs (@\w+)/) do |name,|
            next unless name.is_a?(String)

            file_content << name.to_sym
          end
          @instance_variable_names_map[processed_source.file_path] = file_content
        end

        # @rbs name: Symbol
        # @rbs return: bool
        def instance_variable_missing?(name)
          return false if instance_variable_names.include?(name)

          # report once
          instance_variable_names << name
          true
        end
      end
    end
  end
end
