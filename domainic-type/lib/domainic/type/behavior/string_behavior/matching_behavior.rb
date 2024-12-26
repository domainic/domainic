# frozen_string_literal: true

module Domainic
  module Type
    module Behavior
      module StringBehavior
        # A module providing string matching constraint methods
        #
        # This module extends types with methods for constraining string values based on
        # equality, pattern matching, and substring inclusion/exclusion. It provides a
        # fluent interface for building complex string matching constraints.
        #
        # @example Basic equality constraints
        #   type = StringType.new
        #     .being_equal_to("expected")
        #     .not_being_equal_to("forbidden")
        #
        # @example Pattern matching constraints
        #   type = StringType.new
        #     .matching(/^\w+$/, /[0-9]/)
        #     .not_matching(/admin/i)
        #
        # @example Substring constraints
        #   type = StringType.new
        #     .containing("allowed", "required")
        #     .excluding("forbidden", "blocked")
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        module MatchingBehavior
          # Constrain string to equal a specific value
          #
          # @param literal [String, Symbol] the value to match against
          # @return [Behavior] self for method chaining
          # @rbs (String | Symbol literal) -> Behavior
          def being_equal_to(literal)
            # @type self: Object & Behavior
            constrain :self, :equality, literal, description: 'equaling'
          end
          alias eql being_equal_to
          alias equal_to being_equal_to
          alias equaling being_equal_to

          # Constrain string to contain specific substrings
          #
          # @param literals [Array<String, Symbol>] the required substrings
          # @return [Behavior] self for method chaining
          # @rbs (*String | Symbol literals) -> Behavior
          def containing(*literals)
            # @type self: Object & Behavior
            including = literals.map do |literal|
              @constraints.prepare :self, :inclusion, literal, coerce_with: lambda(&:to_s)
            end
            constrain :self, :and, including, concerning: :inclusion
          end
          alias including containing

          # Constrain string to exclude specific substrings
          #
          # @param literals [Array<String, Symbol>] the forbidden substrings
          # @return [Behavior] self for method chaining
          # @rbs (*String | Symbol literals) -> Behavior
          def excluding(*literals)
            # @type self: Object & Behavior
            including = literals.map do |literal|
              @constraints.prepare :self, :inclusion, literal, coerce_with: lambda(&:to_s)
            end
            constrain :self, :nor, including, concerning: :exclusion
          end
          alias omitting excluding

          # Constrain string to match specific patterns
          #
          # @param patterns [Array<String, Regexp>] the required patterns
          # @return [Behavior] self for method chaining
          # @rbs (*String | Regexp patterns) -> Behavior
          def matching(*patterns)
            # @type self: Object & Behavior
            matching_patterns = patterns.map do |pattern|
              @constraints.prepare :self, :match_pattern, pattern
            end
            constrain :self, :and, matching_patterns, concerning: :pattern_inclusion
          end

          # Constrain string to not equal a specific value
          #
          # @param literal [String, Symbol] the forbidden value
          # @return [Behavior] self for method chaining
          # @rbs (String | Symbol literal) -> Behavior
          def not_being_equal_to(literal)
            # @type self: Object & Behavior
            equal_to = @constraints.prepare :self, :equality, literal
            constrain :self, :not, equal_to, concerning: :equality, description: 'being'
          end
          alias not_eql not_being_equal_to
          alias not_equal_to not_being_equal_to
          alias not_equaling not_being_equal_to

          # Constrain string to not match specific patterns
          #
          # @param patterns [Array<String, Regexp>] the forbidden patterns
          # @return [Behavior] self for method chaining
          # @rbs (*String | Regexp patterns) -> Behavior
          def not_matching(*patterns)
            # @type self: Object & Behavior
            matching_patterns = patterns.map do |pattern|
              @constraints.prepare :self, :match_pattern, pattern
            end
            constrain :self, :nor, matching_patterns, concerning: :pattern_exclusion
          end
        end
      end
    end
  end
end
