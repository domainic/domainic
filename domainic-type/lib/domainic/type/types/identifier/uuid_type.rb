# frozen_string_literal: true

require 'domainic/type/behavior'

module Domainic
  # NOTE: This file is located at lib/domainic/type/types/identifier/uuid_type.rb
  module Type
    # A type for validating UUIDs according to RFC 4122 standards
    #
    # This type provides comprehensive UUID validation following RFC 4122 standards.
    # It supports both standard (hyphenated) and compact formats for all UUID versions
    # (1 through 7), while enforcing proper formatting and version-specific constraints.
    #
    # Key features:
    # - RFC 4122 compliant UUID format validation
    # - Support for versions 1-7
    # - Standard (hyphenated) and compact format support
    # - Length validation (36 chars for standard, 32 for compact)
    # - Version-specific validation
    #
    # @example Basic usage
    #   type = UUIDType.new
    #   type.validate("123e4567-e89b-12d3-a456-426614174000")  # => true
    #   type.validate("invalid")                                # => false
    #
    # @example With version constraints
    #   type = UUIDType.new.being_version(4)
    #   type.validate("123e4567-e89b-42d3-a456-426614174000")  # => true
    #
    # @example With format constraints
    #   type = UUIDType.new.being_compact
    #   type.validate("123e4567e89b12d3a456426614174000")      # => true
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class UUIDType
      # @rbs! extend Behavior::ClassMethods

      include Behavior

      # Contains UUID validation regular expressions and version-specific modules
      #
      # This module provides both standard (hyphenated) and compact format regular
      # expressions for UUID validation, along with version-specific submodules for
      # more granular validation requirements.
      #
      # @since 0.1.0
      module UUID
        # Regular expression for standard (hyphenated) UUID format
        #
        # Validates UUIDs in the format: 8-4-4-4-12 hexadecimal digits with hyphens
        # Example: "123e4567-e89b-12d3-a456-426614174000"
        #
        # @since 0.1.0
        STANDARD_REGEXP = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-7][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i #: Regexp

        # Regular expression for compact (non-hyphenated) UUID format
        #
        # Validates UUIDs in the format: 32 continuous hexadecimal digits
        # Example: "123e4567e89b12d3a456426614174000"
        #
        # @since 0.1.0
        COMPACT_REGEXP = /\A[0-9a-f]{8}[0-9a-f]{4}[1-7][0-9a-f]{3}[89ab][0-9a-f]{3}[0-9a-f]{12}\z/i #: Regexp

        # Version 1 UUID validation patterns
        #
        # Provides regular expressions for validating time-based Version 1 UUIDs.
        # These UUIDs are generated using a timestamp and node ID.
        #
        # @since 0.1.0
        module V1
          # Standard format regex for Version 1 UUIDs
          # @return [Regexp] Pattern matching hyphenated Version 1 UUIDs
          STANDARD_REGEXP = /\A[a-f0-9]{8}-[a-f0-9]{4}-1[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}\z/ #: Regexp

          # Compact format regex for Version 1 UUIDs
          # @return [Regexp] Pattern matching non-hyphenated Version 1 UUIDs
          COMPACT_REGEXP = /\A[a-f0-9]{8}[a-f0-9]{4}1[a-f0-9]{3}[89ab][a-f0-9]{3}[a-f0-9]{12}\z/ #: Regexp
        end

        # Version 2 UUID validation patterns
        #
        # Provides regular expressions for validating DCE Security Version 2 UUIDs.
        # These UUIDs incorporate local domain identifiers.
        #
        # @since 0.1.0
        module V2
          # Standard format regex for Version 2 UUIDs
          # @return [Regexp] Pattern matching hyphenated Version 2 UUIDs
          STANDARD_REGEXP = /\A[a-f0-9]{8}-[a-f0-9]{4}-2[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}\z/ #:Regexp

          # Compact format regex for Version 2 UUIDs
          # @return [Regexp] Pattern matching non-hyphenated Version 2 UUIDs
          COMPACT_REGEXP = /\A[a-f0-9]{8}[a-f0-9]{4}2[a-f0-9]{3}[89ab][a-f0-9]{3}[a-f0-9]{12}\z/ #:Regexp
        end

        # Version 3 UUID validation patterns
        #
        # Provides regular expressions for validating name-based Version 3 UUIDs
        # using MD5 hashing.
        #
        # @since 0.1.0
        module V3
          # Standard format regex for Version 3 UUIDs
          # @return [Regexp] Pattern matching hyphenated Version 3 UUIDs
          STANDARD_REGEXP = /\A[a-f0-9]{8}-[a-f0-9]{4}-3[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}\z/ #:Regexp

          # Compact format regex for Version 3 UUIDs
          # @return [Regexp] Pattern matching non-hyphenated Version 3 UUIDs
          COMPACT_REGEXP = /\A[a-f0-9]{8}[a-f0-9]{4}3[a-f0-9]{3}[89ab][a-f0-9]{3}[a-f0-9]{12}\z/ #:Regexp
        end

        # Version 4 UUID validation patterns
        #
        # Provides regular expressions for validating randomly generated Version 4
        # UUIDs. These are the most commonly used UUID format.
        #
        # @since 0.1.0
        module V4
          # Standard format regex for Version 4 UUIDs
          # @return [Regexp] Pattern matching hyphenated Version 4 UUIDs
          STANDARD_REGEXP = /\A[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}\z/ #:Regexp

          # Compact format regex for Version 4 UUIDs
          # @return [Regexp] Pattern matching non-hyphenated Version 4 UUIDs
          COMPACT_REGEXP = /\A[a-f0-9]{8}[a-f0-9]{4}4[a-f0-9]{3}[89ab][a-f0-9]{3}[a-f0-9]{12}\z/ #:Regexp
        end

        # Version 5 UUID validation patterns
        #
        # Provides regular expressions for validating name-based Version 5 UUIDs
        # using SHA-1 hashing.
        #
        # @since 0.1.0
        module V5
          # Standard format regex for Version 5 UUIDs
          # @return [Regexp] Pattern matching hyphenated Version 5 UUIDs
          STANDARD_REGEXP = /\A[a-f0-9]{8}-[a-f0-9]{4}-5[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}\z/ #:Regexp

          # Compact format regex for Version 5 UUIDs
          # @return [Regexp] Pattern matching non-hyphenated Version 5 UUIDs
          COMPACT_REGEXP = /\A[a-f0-9]{8}[a-f0-9]{4}5[a-f0-9]{3}[89ab][a-f0-9]{3}[a-f0-9]{12}\z/ #:Regexp
        end

        # Version 6 UUID validation patterns
        #
        # Provides regular expressions for validating ordered-time Version 6 UUIDs.
        # These UUIDs are similar to Version 1 but with improved timestamp ordering.
        #
        # @since 0.1.0
        module V6
          # Standard format regex for Version 6 UUIDs
          # @return [Regexp] Pattern matching hyphenated Version 6 UUIDs
          STANDARD_REGEXP = /\A[a-f0-9]{8}-[a-f0-9]{4}-6[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}\z/ #:Regexp

          # Compact format regex for Version 6 UUIDs
          # @return [Regexp] Pattern matching non-hyphenated Version 6 UUIDs
          COMPACT_REGEXP = /\A[a-f0-9]{8}[a-f0-9]{4}6[a-f0-9]{3}[89ab][a-f0-9]{3}[a-f0-9]{12}\z/ #:Regexp
        end

        # Version 7 UUID validation patterns
        #
        # Provides regular expressions for validating Unix Epoch time-based Version 7
        # UUIDs. These UUIDs use millisecond precision timestamps.
        #
        # @since 0.1.0
        module V7
          # Standard format regex for Version 7 UUIDs
          # @return [Regexp] Pattern matching hyphenated Version 7 UUIDs
          STANDARD_REGEXP = /\A[a-f0-9]{8}-[a-f0-9]{4}-7[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}\z/ #:Regexp

          # Compact format regex for Version 7 UUIDs
          # @return [Regexp] Pattern matching non-hyphenated Version 7 UUIDs
          COMPACT_REGEXP = /\A[a-f0-9]{8}[a-f0-9]{4}7[a-f0-9]{3}[89ab][a-f0-9]{3}[a-f0-9]{12}\z/ #:Regexp
        end
      end

      # Core UUID constraints based on RFC 4122
      intrinsically_constrain :self, :type, String, abort_on_failure: true, description: :not_described

      # The base UUID type should accept either standard or compact format
      intrinsically_constrain :self, :match_pattern,
                              Regexp.union(UUID::STANDARD_REGEXP, UUID::COMPACT_REGEXP),
                              description: 'matching UUID format', concerning: :format

      # Length constraint is handled by the format-specific methods
      intrinsically_constrain :length, :range,
                              { minimum: 32, maximum: 36 },
                              description: 'having valid length', concerning: :size

      # Constrain UUID to compact format
      #
      # Creates a constraint ensuring the UUID is in compact format (32 characters,
      # no hyphens). Useful when working with systems that prefer compact UUIDs.
      #
      # @example
      #   type.being_compact
      #   type.validate("123e4567e89b12d3a456426614174000")  # => true
      #   type.validate("123e4567-e89b-12d3-a456-426614174000")  # => false
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_compact
        constrain :length, :range, { minimum: 32, maximum: 32 },
                  concerning: :size, description: 'having compact format length'
        constrain :self, :match_pattern, UUID::COMPACT_REGEXP,
                  description: 'matching compact UUID format',
                  concerning: :format
      end
      alias compact being_compact

      # Constrain UUID to standard format
      #
      # Creates a constraint ensuring the UUID is in standard format (36 characters,
      # with hyphens). This is the default format per RFC 4122.
      #
      # @example
      #   type.being_standard
      #   type.validate("123e4567-e89b-12d3-a456-426614174000")  # => true
      #   type.validate("123e4567e89b12d3a456426614174000")      # => false
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_standard
        constrain :length, :range, { minimum: 36, maximum: 36 },
                  concerning: :size, description: 'having standard format length'
        constrain :self, :match_pattern, UUID::STANDARD_REGEXP,
                  description: 'matching standard UUID format',
                  concerning: :format
      end
      alias standard being_standard

      # Constrain UUID to specific version
      #
      # Creates a constraint ensuring the UUID matches a specific version (1-7) in
      # either standard or compact format.
      #
      # @example
      #   type.being_version(4)
      #   type.validate("123e4567-e89b-42d3-a456-426614174000")  # => true
      #   type.validate("123e4567-e89b-12d3-a456-426614174000")  # => false
      #
      # @param version [Integer] UUID version (1-7)
      # @param format [Symbol] :standard or :compact
      # @return [self] self for method chaining
      # @raise [ArgumentError] if format is neither :standard nor :compact
      # @rbs (Integer version, ?format: :compact | :standard) -> self
      def being_version(version, format: :standard)
        case format
        when :compact
          constrain :length, :range, { minimum: 32, maximum: 32 },
                    concerning: :size, description: 'having length'
        when :standard
          constrain :length, :range, { minimum: 36, maximum: 36 },
                    concerning: :size, description: 'having length'
        else
          raise ArgumentError, "Invalid format: #{format}. Must be :compact or :standard"
        end

        constrain :self, :match_pattern, UUID.const_get("V#{version}::#{format.upcase}_REGEXP"),
                  concerning: :version
      end

      # Constrain UUID to Version 5 compact format
      #
      # Creates a constraint ensuring the UUID is a Version 5 UUID in compact format.
      # Version 5 UUIDs are name-based using SHA-1 hashing.
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_five_compact
        being_version(5, format: :compact)
      end
      alias being_v5_compact being_version_five_compact
      alias v5_compact being_version_five_compact

      # Constrain UUID to Version 5 standard format
      #
      # Creates a constraint ensuring the UUID is a Version 5 UUID in standard format.
      # Version 5 UUIDs are name-based using SHA-1 hashing.
      #
      # @example
      #   type.being_v5
      #   type.validate("123e4567-e89b-52d3-a456-426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_five_standard
        being_version(5)
      end
      alias being_v5 being_version_five_standard
      alias being_v5_standard being_version_five_standard
      alias being_version_five being_version_five_standard
      alias v5 being_version_five_standard

      # Constrain UUID to Version 4 compact format
      #
      # Creates a constraint ensuring the UUID is a Version 4 UUID in compact format.
      # Version 4 UUIDs are randomly generated and are the most commonly used format.
      #
      # @example
      #   type.being_v4_compact
      #   type.validate("123e4567e89b42d3a456426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_four_compact
        being_version(4, format: :compact)
      end
      alias being_v4_compact being_version_four_compact
      alias v4_compact being_version_four_compact

      # Constrain UUID to Version 4 standard format
      #
      # Creates a constraint ensuring the UUID is a Version 4 UUID in standard format.
      # Version 4 UUIDs are randomly generated and are the most commonly used format.
      #
      # @example
      #   type.being_v4
      #   type.validate("123e4567-e89b-42d3-a456-426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_four_standard
        being_version(4)
      end
      alias being_v4 being_version_four_standard
      alias being_v4_standard being_version_four_standard
      alias being_version_four being_version_four_standard
      alias v4 being_version_four_standard

      # Constrain UUID to Version 1 compact format
      #
      # Creates a constraint ensuring the UUID is a Version 1 UUID in compact format.
      # Version 1 UUIDs are time-based using a timestamp and node ID.
      #
      # @example
      #   type.being_v1_compact
      #   type.validate("123e4567e89b12d3a456426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_one_compact
        being_version(1, format: :compact)
      end
      alias being_v1_compact being_version_one_compact
      alias v1_compact being_version_one_compact

      # Constrain UUID to Version 1 standard format
      #
      # Creates a constraint ensuring the UUID is a Version 1 UUID in standard format.
      # Version 1 UUIDs are time-based using a timestamp and node ID.
      #
      # @example
      #   type.being_v1
      #   type.validate("123e4567-e89b-12d3-a456-426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_one_standard
        being_version(1)
      end
      alias being_v1 being_version_one_standard
      alias being_v1_standard being_version_one_standard
      alias being_version_one being_version_one_standard
      alias v1 being_version_one_standard

      # Constrain UUID to Version 7 compact format
      #
      # Creates a constraint ensuring the UUID is a Version 7 UUID in compact format.
      # Version 7 UUIDs use Unix Epoch timestamps with millisecond precision.
      #
      # @example
      #   type.being_v7_compact
      #   type.validate("123e4567e89b72d3a456426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_seven_compact
        being_version(7, format: :compact)
      end
      alias being_v7_compact being_version_seven_compact
      alias v7_compact being_version_seven_compact

      # Constrain UUID to Version 7 standard format
      #
      # Creates a constraint ensuring the UUID is a Version 7 UUID in standard format.
      # Version 7 UUIDs use Unix Epoch timestamps with millisecond precision.
      #
      # @example
      #   type.being_v7
      #   type.validate("123e4567-e89b-72d3-a456-426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_seven_standard
        being_version(7)
      end
      alias being_v7 being_version_seven_standard
      alias being_v7_standard being_version_seven_standard
      alias being_version_seven being_version_seven_standard
      alias v7 being_version_seven_standard

      # Constrain UUID to Version 6 compact format
      #
      # Creates a constraint ensuring the UUID is a Version 6 UUID in compact format.
      # Version 6 UUIDs are similar to Version 1 but with improved timestamp ordering.
      #
      # @example
      #   type.being_v6_compact
      #   type.validate("123e4567e89b62d3a456426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_six_compact
        being_version(6, format: :compact)
      end
      alias being_v6_compact being_version_six_compact
      alias v6_compact being_version_six_compact

      # Constrain UUID to Version 6 standard format
      #
      # Creates a constraint ensuring the UUID is a Version 6 UUID in standard format.
      # Version 6 UUIDs are similar to Version 1 but with improved timestamp ordering.
      #
      # @example
      #   type.being_v6
      #   type.validate("123e4567-e89b-62d3-a456-426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_six_standard
        being_version(6)
      end
      alias being_v6 being_version_six_standard
      alias being_v6_standard being_version_six_standard
      alias being_version_six being_version_six_standard
      alias v6 being_version_six_standard

      # Constrain UUID to Version 3 compact format
      #
      # Creates a constraint ensuring the UUID is a Version 3 UUID in compact format.
      # Version 3 UUIDs are name-based using MD5 hashing.
      #
      # @example
      #   type.being_v3_compact
      #   type.validate("123e4567e89b32d3a456426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_three_compact
        being_version(3, format: :compact)
      end
      alias being_v3_compact being_version_three_compact
      alias v3_compact being_version_three_compact

      # Constrain UUID to Version 3 standard format
      #
      # Creates a constraint ensuring the UUID is a Version 3 UUID in standard format.
      # Version 3 UUIDs are name-based using MD5 hashing.
      #
      # @example
      #   type.being_v3
      #   type.validate("123e4567-e89b-32d3-a456-426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_three_standard
        being_version(3)
      end
      alias being_v3 being_version_three_standard
      alias being_v3_standard being_version_three_standard
      alias being_version_three being_version_three_standard
      alias v3 being_version_three_standard

      # Constrain UUID to Version 2 compact format
      #
      # Creates a constraint ensuring the UUID is a Version 2 UUID in compact format.
      # Version 2 UUIDs are DCE Security version that incorporate local domain identifiers.
      #
      # @example
      #   type.being_v2_compact
      #   type.validate("123e4567e89b22d3a456426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_two_compact
        being_version(2, format: :compact)
      end
      alias being_v2_compact being_version_two_compact
      alias v2_compact being_version_two_compact

      # Constrain UUID to Version 2 standard format
      #
      # Creates a constraint ensuring the UUID is a Version 2 UUID in standard format.
      # Version 2 UUIDs are DCE Security version that incorporate local domain identifiers.
      #
      # @example
      #   type.being_v2
      #   type.validate("123e4567-e89b-22d3-a456-426614174000")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_two_standard
        being_version(2)
      end
      alias being_v2 being_version_two_standard
      alias being_v2_standard being_version_two_standard
      alias being_version_two being_version_two_standard
      alias v2 being_version_two_standard
    end
  end
end
