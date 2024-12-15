# frozen_string_literal: true

module Domainic
  module Type
    module Constraint
      # @since 0.1.0
      class Resolver
        # @rbs @constant_name: String
        # @rbs @constraint_name: Symbol
        # @rbs @file_name: String

        # @rbs (Symbol constraint_type) -> _Class
        def self.resolve!(constraint_type)
          new(constraint_type).resolve!
        end

        # @rbs (Symbol constraint_type) -> void
        def initialize(constraint_name)
          @constraint_name = constraint_name
        end

        # @rbs () -> _Class
        def resolve!
          load_constraint!
          constraint_class
        end

        private

        # @rbs () -> String
        def constant_name
          @constant_name ||= file_name.split('_').map(&:capitalize).join
        end

        # @rbs () -> _Class
        def constraint_class
          constant = Domainic::Type::Constraint.const_get(constant_name)
          raise ArgumentError, "Unknown constraint: #{@constraint_name}" if constant.nil?

          constant
        end

        # @rbs () -> String
        def file_name
          @file_name ||= "#{@constraint_name.to_s.delete_suffix('?').delete_suffix('!')}_constraint"
        end

        # @rbs () -> void
        def load_constraint!
          require "domainic/type/constraint/constraints/#{file_name}"
        rescue LoadError
          raise ArgumentError, "Unknown constraint: #{@constraint_name}"
        end
      end
    end
  end
end
