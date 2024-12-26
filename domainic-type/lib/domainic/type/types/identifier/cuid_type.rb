# frozen_string_literal: true

require 'domainic/type/behavior'

module Domainic
  module Type
    # A type for validating CUIDs according to official specifications
    #
    # This type provides comprehensive CUID validation following the official
    # CUID specifications. It supports both v1 and v2 formats, with proper
    # format-specific validation.
    #
    # Key features:
    # - CUID v1 validation (25 characters, c-prefix)
    # - CUID v2 validation (variable length 14-24 chars)
    # - Length validation
    # - Character set validation
    #
    # @example Basic usage
    #   type = CUIDType.new
    #   type.validate("ch72gsb320000udocl363eofy")  # => true
    #   type.validate("invalid")                     # => false
    #
    # @example With version constraints
    #   type = CUIDType.new.being_version(2)
    #   type.validate("clh3am1f30000udocbhqg4151")  # => true
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class CUIDType
      # @rbs! extend Behavior::ClassMethods

      include Behavior

      # Contains CUID validation regular expressions and version-specific modules
      #
      # This module provides validation patterns for both CUID v1 and v2 formats,
      # following the official specification.
      #
      # @since 0.1.0
      module CUID
        # Regular expression for CUID v1 format
        #
        # Validates CUIDs in v1 format: c-prefix + 24 lowercase alphanumeric chars
        # Example: "ch72gsb320000udocl363eofy"
        #
        # @since 0.1.0
        V1_REGEXP = /\Ac[a-z0-9]{24}\z/ #: Regexp

        # Regular expression for CUID v2 format
        #
        # Validates CUIDs in v2 format: k-p prefix + 13-23 lowercase alphanumeric chars
        # Example: "clh3am1f30000udocbhqg4151"
        #
        # @since 0.1.0
        V2_REGEXP = /\A[k-p][a-z0-9]{13,23}\z/ #: Regexp

        # Regular expression for any valid CUID (v1 or v2)
        ALL_REGEXP = Regexp.union(V1_REGEXP, V2_REGEXP) #: Regexp
      end

      # Core CUID constraints
      intrinsically_constrain :self, :type, String, description: :not_described

      # Accept either v1 or v2 format by default
      intrinsically_constrain :self, :match_pattern, CUID::ALL_REGEXP,
                              description: 'CUID format', concerning: :format

      # Length constraint covers both v1 (25 chars) and v2 (14-24 chars)
      intrinsically_constrain :length, :range, { minimum: 14, maximum: 25 },
                              description: 'having', concerning: :size

      # Constrain CUID to specific version
      #
      # Creates a constraint ensuring the CUID matches a specific version (1 or 2).
      #
      # @example
      #   type.being_version(1)
      #   type.validate("ch72gsb320000udocl363eofy")  # => true
      #
      # @param version [Integer] CUID version (1 or 2)
      # @return [self] self for method chaining
      # @raise [ArgumentError] if version is neither 1 nor 2
      # @rbs (Integer version) -> self
      def being_version(version)
        case version
        when 1 then being_version_one
        when 2 then being_version_two
        else
          raise ArgumentError, "Invalid version: #{version}. Must be 1 or 2"
        end
      end
      alias version being_version

      # Constrain CUID to Version 1
      #
      # Creates a constraint ensuring the CUID is a Version 1 CUID.
      # Version 1 CUIDs are 25 characters long and start with 'c'.
      #
      # @example
      #   type.being_version_one
      #   type.validate("ch72gsb320000udocl363eofy")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_one
        constrain :length, :range, { minimum: 25, maximum: 25 },
                  concerning: :size, description: 'having v1 length'
        constrain :self, :match_pattern, CUID::V1_REGEXP,
                  description: 'v1 CUID format',
                  concerning: :version
      end
      alias being_v1 being_version_one
      alias v1 being_version_one
      alias version_one being_version_one

      # Constrain CUID to Version 2
      #
      # Creates a constraint ensuring the CUID is a Version 2 CUID.
      # Version 2 CUIDs are 14-24 characters and start with k-p.
      #
      # @example
      #   type.being_version_two
      #   type.validate("clh3am1f30000udocbhqg4151")  # => true
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def being_version_two
        constrain :length, :range, { minimum: 14, maximum: 24 },
                  concerning: :size, description: 'having v2 length'
        constrain :self, :match_pattern, CUID::V2_REGEXP,
                  description: 'v2 CUID format',
                  concerning: :version
      end
      alias being_v2 being_version_two
      alias v2 being_version_two
      alias version_two being_version_two
    end
  end
end
