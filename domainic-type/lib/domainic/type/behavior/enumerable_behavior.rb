# frozen_string_literal: true

require 'domainic/type/behavior'

module Domainic
  module Type
    module Behavior
      # @since 0.1.0
      # @rbs module-self Behavior
      module EnumerableBehavior
        # @rbs () -> EnumerableBehavior
        def being_duplicative
          sub_constraint = Constraint::Resolver.new(:uniqueness).resolve!.new(:self)
          add_constraint :self, :uniqueness, :not, sub_constraint
        end

        # @rbs () -> EnumerableBehavior
        def being_empty
          add_constraint :self, :population, :emptiness
        end

        # @rbs () -> EnumerableBehavior
        def being_populated
          sub_constraint = Constraint::Resolver.new(:emptiness).resolve!.new(:self)
          add_constraint :self, :population, :not, sub_constraint
        end

        # @rbs (Integer count) -> EnumerableBehavior
        def having_maximum_count(count)
          add_constraint :count, :count, :range, { maximum: count }
        end

        # @rbs (Integer count) -> EnumerableBehavior
        def having_minimum_count(count)
          add_constraint :count, :count, :range, { minimum: count }
        end

        # @rbs (Class | Module | Behavior type) -> EnumerableBehavior
        def of(type)
          sub_constraint = Constraint::Resolver.new(:type).resolve!.new(:self, type)
          add_constraint :self, :element_type, :all, sub_constraint
        end
      end
    end
  end
end
