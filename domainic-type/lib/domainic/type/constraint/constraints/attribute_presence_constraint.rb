# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/constraint/behavior'

module Domainic
  module Type
    module Constraint
      # A constraint that validates the presence and types of object attributes
      #
      # This constraint verifies that objects respond to specified attributes and that
      # those attributes return values matching their corresponding type constraints.
      # It supports both Ruby core types (Class/Module) and custom type constraints
      # that implement the Type::Behavior interface.
      #
      # @example Basic attribute validation
      #   # Validate presence and basic Ruby types
      #   constraint = AttributePresenceConstraint.new(:self,
      #     username: String,
      #     age: Integer
      #   )
      #
      #   # Success case
      #   user = User.new(username: "alice", age: 30)
      #   constraint.satisfied?(user) # => true
      #
      #   # Missing attribute failure
      #   user = User.new(username: "bob")
      #   constraint.satisfied?(user) # => false
      #   constraint.short_violation_description # => "missing attributes: age"
      #
      #   # Wrong type failure
      #   user = User.new(username: 123, age: "30")
      #   constraint.satisfied?(user) # => false
      #   constraint.short_violation_description
      #     # => "invalid attributes: username: 123, age: \"30\""
      #
      # @example With custom type constraints
      #   # Combine with other type constraints
      #   constraint = AttributePresenceConstraint.new(:self,
      #     username: _String.having_size_between(3, 20),
      #     role: _Enum(:admin, :user),
      #     email: _String.matching(/@/)
      #   )
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class AttributePresenceConstraint
        include Behavior #[Hash[Symbol, Class | Module | Type::Behavior], untyped, {}]

        # Get a description of what the constraint expects
        #
        # @return [String] the constraint description
        # @rbs override
        def short_description
          "attributes #{@expected.map { |attribute, type| "#{attribute}: #{type.inspect}" }.join(', ')}".strip
        end

        # Get a description of why the constraint was violated
        #
        # @return [String] the violation description
        # @rbs override
        def short_violation_description
          missing, invalid = violations
          return '' if missing.empty? && invalid.empty?

          # @type var missing: Array[Symbol]
          # @type var invalid: Array[Symbol]

          [
            missing.empty? ? nil : "missing attributes: #{missing.join(', ')}",
            invalid.empty? ? nil : "invalid attributes: #{format_invalid_attributes(invalid)}"
          ].compact.join(' and ')
        end

        protected

        # Coerce expectation hash keys into symbols
        #
        # @param expectation [Hash] the raw expectation hash
        #
        # @return [Hash] the coerced expectation
        # @rbs override
        def coerce_expectation(expectation)
          return expectation unless expectation.is_a?(Hash)

          expectation.transform_keys(&:to_sym)
        end

        # Format the list of invalid attributes for error messages
        #
        # @param invalid [Array<Symbol>] The list of invalid attribute names
        #
        # @return [String] formatted error message
        # @rbs (Array[Symbol] invalid) -> String
        def format_invalid_attributes(invalid)
          invalid.map do |attribute| # use filter_map to exclude nil entries
            "#{attribute}: #{@actual.public_send(attribute).inspect}"
          end.join(', ')
        end

        # Check if the constraint is satisfied
        #
        # @return [Boolean] whether all attributes exist and have valid types
        # @rbs override
        def satisfies_constraint?
          violations.all?(&:empty?)
        end

        # Check if a value satisfies a type constraint
        #
        # @param value [Object] the value to check
        # @param type [Class, Module, Type::Behavior] the type to check against
        #
        # @return [Boolean] whether the value matches the type
        # @rbs (untyped value, Class | Module | Type::Behavior type) -> bool
        def satisfies_type?(value, type)
          type === value || value.is_a?(type) # rubocop:disable Style/CaseEquality
        end

        # Validate the format of the expectation hash
        #
        # @param expectation [Hash] the expectation to validate
        #
        # @raise [ArgumentError] if the expectation is invalid
        # @return [void]
        # @rbs override
        def validate_expectation!(expectation)
          raise ArgumentError, 'Expectation must be a Hash' unless expectation.is_a?(Hash)
          raise ArgumentError, 'Expectation must have symbolized keys' unless expectation.keys.all?(Symbol)

          expectation.each_value do |value|
            next if [Class, Module, Type::Behavior].any? { |type| value.is_a?(type) }

            raise ArgumentError, 'Expectation must have values of Class, Module, or Domainic::Type'
          end
        end

        # Get lists of missing and invalid attributes
        #
        # @return [Array(Array<Symbol>, Array<Symbol>)] missing and invalid attribute lists
        # @rbs () -> Array[Array[Symbol]]
        def violations
          @violations ||= begin
            missing = @expected.keys.reject { |attribute| @actual.respond_to?(attribute) }
            invalid = @expected.reject do |attribute, type|
              missing.include?(attribute) || satisfies_type?(@actual.public_send(attribute), type)
            end.keys
            [missing, invalid] #: Array[Array[Symbol]]
          end
        end
      end
    end
  end
end
