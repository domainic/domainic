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
        alias being_non_unique being_duplicative
        alias duplicative being_duplicative
        alias having_duplicate_elements being_duplicative
        alias having_duplicate_entries being_duplicative
        alias having_duplicate_members being_duplicative
        alias with_duplicate_elements being_duplicative
        alias with_duplicate_entries being_duplicative
        alias with_duplicate_members being_duplicative

        # @rbs () -> EnumerableBehavior
        def being_empty
          add_constraint :self, :population, :emptiness
        end
        alias empty being_empty
        alias having_no_elements being_empty
        alias having_no_entries being_empty
        alias having_no_members being_empty
        alias having_zero_elements being_empty
        alias having_zero_entries being_empty
        alias having_zero_members being_empty
        alias with_no_elements being_empty
        alias with_no_entries being_empty
        alias with_no_members being_empty
        alias with_zero_elements being_empty
        alias with_zero_entries being_empty
        alias with_zero_members being_empty

        # @rbs () -> EnumerableBehavior
        def being_populated
          sub_constraint = Constraint::Resolver.new(:emptiness).resolve!.new(:self)
          add_constraint :self, :population, :not, sub_constraint
        end
        alias having_elements being_populated
        alias having_entries being_populated
        alias having_members being_populated
        alias non_empty being_populated
        alias populated being_populated
        alias with_elements being_populated
        alias with_entries being_populated
        alias with_members being_populated

        # @rbs (Integer count) -> EnumerableBehavior
        def having_maximum_count(count)
          add_constraint :count, :count, :range, { maximum: count }
        end
        alias having_max_count having_maximum_count
        alias having_max_len having_maximum_count
        alias having_max_length having_maximum_count
        alias having_max_size having_maximum_count
        alias having_maximum_len having_maximum_count
        alias having_maximum_length having_maximum_count
        alias having_maximum_size having_maximum_count
        alias max_count having_maximum_count
        alias max_len having_maximum_count
        alias max_length having_maximum_count
        alias max_size having_maximum_count
        alias maximum_count having_maximum_count
        alias maximum_len having_maximum_count
        alias maximum_length having_maximum_count
        alias maximum_size having_maximum_count
        alias with_max_count having_maximum_count
        alias with_max_len having_maximum_count
        alias with_max_length having_maximum_count
        alias with_max_size having_maximum_count
        alias with_maximum_count having_maximum_count
        alias with_maximum_len having_maximum_count
        alias with_maximum_length having_maximum_count
        alias with_maximum_size having_maximum_count

        # @rbs (Integer count) -> EnumerableBehavior
        def having_minimum_count(count)
          add_constraint :count, :count, :range, { minimum: count }
        end
        alias having_min_count having_minimum_count
        alias having_min_len having_minimum_count
        alias having_min_length having_minimum_count
        alias having_min_size having_minimum_count
        alias having_minimum_len having_minimum_count
        alias having_minimum_length having_minimum_count
        alias having_minimum_size having_minimum_count
        alias min_count having_minimum_count
        alias min_len having_minimum_count
        alias min_length having_minimum_count
        alias min_size having_minimum_count
        alias minimum_count having_minimum_count
        alias minimum_len having_minimum_count
        alias minimum_length having_minimum_count
        alias minimum_size having_minimum_count
        alias with_min_count having_minimum_count
        alias with_min_len having_minimum_count
        alias with_min_length having_minimum_count
        alias with_min_size having_minimum_count
        alias with_minimum_count having_minimum_count
        alias with_minimum_len having_minimum_count
        alias with_minimum_length having_minimum_count
        alias with_minimum_size having_minimum_count

        # @rbs (Class | Module | Behavior type) -> EnumerableBehavior
        def of(type)
          sub_constraint = Constraint::Resolver.new(:type).resolve!.new(:self, type)
          add_constraint :self, :element_type, :all, sub_constraint
        end
        alias having_elements_of of
        alias having_members_of of
        alias having_items_of of
        alias with_elements_of of
        alias with_members_of of
        alias with_items_of of
      end
    end
  end
end
