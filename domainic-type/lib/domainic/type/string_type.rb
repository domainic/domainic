# frozen_string_literal: true

require_relative 'base_type'

module Domainic
  module Type
    # @since 0.1.0
    class StringType < BaseType
      constrain :self do
        intrinsic_constraint :type, expected: String, fail_fast: true

        constraint :inclusion, name: :exclusion
        constraint :inclusion
        constraint :match
        constraint :ordering
        constraint :presence
        constraint :uniqueness

        bind_method :being_blank do
          desc 'Constrains the string to be blank.'
          concerning :presence

          configure { { condition: :absent } }
        end

        bind_method :being_duplicative do
          desc 'Constrains the string to be duplicative.'
          concerning :uniqueness

          configure { |boolean = true| { condition: :duplicative, negated: !boolean } }
        end

        bind_method :being_ordered do
          desc 'Constrains the string to be ordered.'
          concerning :ordering

          configure { |boolean = true| { condition: :ordered, negated: !boolean } }
        end

        bind_method :being_unique do
          desc 'Constrains the string to be unique.'
          concerning :uniqueness

          configure { |boolean = true| { condition: :unique, negated: !boolean } }
        end

        bind_method :containing do
          desc 'Constrains the string to include the given substring.'
          concerning :inclusion
          aliases :including

          configure { |*values| { expected: (constraints.self&.inclusion&.expected || []).concat(values).uniq } }
        end

        bind_method :excluding do
          desc 'Constrains the string to not include the given substring.'
          concerning :exclusion
          default_for_parameter :expectation_qualifier, :none
          aliases :without

          configure { |*values| { expected: (constraints.self&.exclusion&.expected || []).concat(values).uniq } }
        end

        bind_method :matching do
          desc 'Constrains the string to match the given pattern.'
          concerning :match
          aliases :matching_pattern

          configure { |pattern| { expected: pattern } }
        end

        bind_method :not_being_blank do
          desc 'Constrains the string to not be blank.'
          concerning :presence

          configure { { condition: :present } }
        end
      end

      constrain :length do
        constraint :range

        bind_method :having_exact_length do
          desc 'Constrains the length of the string to be exactly the given length.'
          concerning :range
          aliases :with_exact_length

          configure { |value| { minimum: value, maximum: value } }
        end

        bind_method :having_maximum_length do
          desc 'Constrains the length of the string to be at most the given length.'
          concerning :range
          aliases :with_maximum_length

          configure { |value| { maximum: value } }
        end

        bind_method :having_minimum_length do
          desc 'Constrains the length of the string to be at least the given length.'
          concerning :range
          aliases :with_minimum_length

          configure { |value| { minimum: value } }
        end

        bind_method :having_length_between do
          desc 'Constrains the length of the string to be between the given minimum and maximum lengths.'
          concerning :range
          default_for_parameter :inclusive, false
          aliases :with_length_between

          configure do |minimum = nil, maximum = nil, **options|
            minimum = minimum || options[:minimum] || options[:min]
            maximum = maximum || options[:maximum] || options[:max]
            { minimum:, maximum: }
          end
        end
      end
    end
  end
end
