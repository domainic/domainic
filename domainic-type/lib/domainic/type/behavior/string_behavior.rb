# frozen_string_literal: true

require 'domainic/type/behavior/string_behavior/matching_behavior'
require 'domainic/type/behavior/sizable_behavior'

module Domainic
  module Type
    module Behavior
      # A module providing string-specific validation behaviors for types.
      #
      # This module extends the base Type::Behavior with methods specifically designed for
      # validating string values. It provides a fluent interface for common string validations
      # such as case checking, character set validation, equality, and pattern matching.
      #
      # Key capabilities:
      # - Case validation (upper, lower, mixed, title case)
      # - Character set checking (ASCII, alphanumeric, letters, numbers)
      # - Pattern matching with regular expressions
      # - Substring inclusion/exclusion
      # - Character ordering checks
      # - Length constraints (via SizableBehavior)
      #
      # @example Basic string validation
      #   class StringType
      #     include Domainic::Type::Behavior::StringBehavior
      #
      #     def initialize
      #       super
      #       being_ascii             # validates ASCII characters only
      #       being_alphanumeric      # validates letters and numbers only
      #       having_minimum_size(5)  # validates minimum length
      #     end
      #   end
      #
      # @example Complex string validation
      #   class UsernameType
      #     include Domainic::Type::Behavior::StringBehavior
      #
      #     def initialize
      #       super
      #       being_lowercase
      #       being_alphanumeric
      #       having_size_between(3, 20)
      #       not_matching(/^admin/i)  # prevent admin-like usernames
      #     end
      #   end
      #
      # @example Building constraints dynamically
      #   type = StringType.new
      #     .being_ascii
      #     .being_titlecase
      #     .having_size_between(5, 50)
      #     .matching(/^[A-Z]/)
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      module StringBehavior
        include MatchingBehavior
        include SizableBehavior

        # Validate string contains only alphanumeric characters.
        #
        # @example
        #   type.being_alphanumeric
        #   type.validate("abc123")   # => true
        #   type.validate("abc-123")  # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_alphanumeric
          # @type self: Object & Behavior
          constrain :self, :character_set, :alphanumeric, description: 'being'
        end
        alias alphanumeric being_alphanumeric

        # Validate string contains only ASCII characters.
        #
        # @example
        #   type.being_ascii
        #   type.validate("hello")  # => true
        #   type.validate("héllo")  # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_ascii
          # @type self: Object & Behavior
          constrain :self, :character_set, :ascii, description: 'being'
        end
        alias ascii being_ascii
        alias ascii_only being_ascii

        # Validate string is empty.
        #
        # @example
        #   type.being_empty
        #   type.validate("")    # => true
        #   type.validate("a")   # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_empty
          # @type self: Object & Behavior
          constrain :self, :emptiness, description: 'being'
        end
        alias empty being_empty

        # Validate string is lowercase.
        #
        # @example
        #   type.being_lowercase
        #   type.validate("hello")  # => true
        #   type.validate("Hello")  # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_lowercase
          # @type self: Object & Behavior
          constrain :self, :case, :lower, description: 'being'
        end
        alias lowercase being_lowercase
        alias not_being_uppercase being_lowercase

        # Validate string contains both uppercase and lowercase characters.
        #
        # @example
        #   type.being_mixedcase
        #   type.validate("helloWORLD")  # => true
        #   type.validate("hello")       # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_mixedcase
          # @type self: Object & Behavior
          constrain :self, :case, :mixed, description: 'being'
        end
        alias mixedcase being_mixedcase

        # Validate string contains only letters.
        #
        # @example
        #   type.being_only_letters
        #   type.validate("hello")     # => true
        #   type.validate("hello123")  # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_only_letters
          # @type self: Object & Behavior
          constrain :self, :character_set, :alpha, description: 'being'
        end
        alias alpha being_only_letters
        alias letters_only being_only_letters
        alias only_letters being_only_letters

        # Validate string contains only numbers.
        #
        # @example
        #   type.being_only_numbers
        #   type.validate("123")     # => true
        #   type.validate("abc123")  # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_only_numbers
          # @type self: Object & Behavior
          constrain :self, :character_set, :numeric, description: 'being'
        end
        alias digits_only being_only_numbers
        alias numbers_only being_only_numbers
        alias numeric being_only_numbers
        alias only_digits being_only_numbers
        alias only_numbers being_only_numbers

        # Validate string characters are in sorted order.
        #
        # @example
        #   type.being_ordered
        #   type.validate("abcd")  # => true
        #   type.validate("dcba")  # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_ordered
          # @type self: Object & Behavior
          constrain :chars, :ordering, description: 'being'
        end
        alias not_being_unordered being_ordered
        alias ordered being_ordered

        # Validate string contains only printable characters.
        #
        # @example
        #   type.being_printable
        #   type.validate("Hello!")           # => true
        #   type.validate("Hello\x00World")   # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_printable
          # @type self: Object & Behavior
          constrain :self, :character_set, :printable, description: 'being'
        end
        alias printable being_printable

        # Validate string is in title case (first letter of each word capitalized).
        #
        # @example
        #   type.being_titlecase
        #   type.validate("Hello World")  # => true
        #   type.validate("hello world")  # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_titlecase
          # @type self: Object & Behavior
          constrain :self, :case, :title, description: 'being', coerce_with: lambda(&:to_s)
        end
        alias titlecase being_titlecase

        # Validate string characters are not in sorted order.
        #
        # @example
        #   type.being_unordered
        #   type.validate("dcba")  # => true
        #   type.validate("abcd")  # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_unordered
          # @type self: Object & Behavior
          ordered = @constraints.prepare :chars, :ordering, coerce_with: lambda(&:to_s)
          constrain :self, :not, ordered, concerning: :ordering, description: 'being'
        end
        alias not_being_ordered being_unordered
        alias unordered being_unordered

        # Validate string is uppercase.
        #
        # @example
        #   type.being_uppercase
        #   type.validate("HELLO")  # => true
        #   type.validate("Hello")  # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def being_uppercase
          # @type self: Object & Behavior
          constrain :self, :case, :upper, description: 'being'
        end
        alias not_being_lowercase being_uppercase
        alias uppercase being_uppercase

        # Validate string is not empty.
        #
        # @example
        #   type.not_being_empty
        #   type.validate("a")   # => true
        #   type.validate("")    # => false
        #
        # @return [Behavior] self for method chaining
        # @rbs () -> Behavior
        def not_being_empty
          # @type self: Object & Behavior
          empty = @constraints.prepare :self, :emptiness
          constrain :self, :not, empty, concerning: :emptiness, description: 'being'
        end
      end
    end
  end
end
