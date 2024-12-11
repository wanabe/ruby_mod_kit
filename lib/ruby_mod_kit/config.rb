# frozen_string_literal: true

# rbs_inline: enabled

require "yaml"

module RubyModKit
  # config class
  class Config
    # @rbs @features: Array[Config]

    attr_reader :features #: Array[Config]

    DEFAULT_FEATURES = %w[instance_variable_parameter overload type type/rbs_inline].freeze #: Array[String]

    # @rbs features: Array[String]
    # @rbs return: void
    def initialize(features: DEFAULT_FEATURES)
      @features = features.sort.map do |feature_name|
        raise ArgumentError, "invalid feature: #{feature_name}" if feature_name.include?(".")

        require "ruby_mod_kit/feature/#{feature_name}"
        const_name = feature_name
          .gsub(/[A-Za-z0-9]+/) { (::Regexp.last_match(0) || "").capitalize }
          .gsub("_", "").gsub("/", "::")
        Feature.const_get(const_name).new
      end
    end

    class << self
      # @rbs path: String
      # @rbs if_none: Symbol | nil
      # @rbs return: Config | nil
      def load(path, if_none: nil)
        return load(File.join(path, ".ruby_mod_kit.yml"), if_none: if_none) if File.directory?(path)

        unless File.exist?(path)
          case if_none
          when nil
            return nil
          when :raise
            raise LoadError, "Can't load #{path}"
          else
            raise ArgumentError, "unexpected if_none: #{if_none.inspect}"
          end
        end

        options = YAML.safe_load(File.read(path), symbolize_names: true)
        new(**options) if options.is_a?(Hash)
      end
    end
  end
end
