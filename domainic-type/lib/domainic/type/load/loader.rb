# frozen_string_literal: true

require 'forwardable'

require_relative 'simple_loader'

module Domainic
  module Type
    module Load
      # @since 0.1.0
      class Loader
        extend Forwardable
        def_delegators :@simple, :aliases, :aliased_as?, :constant, :groups, :in_group?, :load, :loaded?, :name

        attr_reader :simple

        def initialize(**options)
          @simple = SimpleLoader.new(**options)
        end

        def add_alias(*alias_names)
          simple.instance_variable_set(
            :@aliases,
            simple.instance_variable_get(:@aliases).concat(alias_names).map(&:to_sym).uniq
          )
        end

        def add_group(*group_names)
          simple.instance_variable_set(
            :@groups,
            simple.instance_variable_get(:@groups).concat(group_names).map(&:to_sym).uniq
          )
        end

        def remove_alias(*alias_names)
          simple.instance_variable_set(
            :@aliases,
            simple.instance_variable_get(:@aliases).reject { |name| alias_names.include?(name) }.map(&:to_sym).uniq
          )
        end

        def remove_group(*group_names)
          simple.instance_variable_set(
            :@groups,
            simple.instance_variable_get(:@groups).reject { |name| group_names.include?(name) }.map(&:to_sym).uniq
          )
        end
      end
    end
  end
end
