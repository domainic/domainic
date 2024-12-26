# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/string_behavior/matching_behavior'
require 'domainic/type/behavior/sizable_behavior'
require 'domainic/type/behavior/uri_behavior'

module Domainic
  module Type
    # A type for validating hostnames according to RFC 1034 and RFC 1123 standards
    #
    # This type provides comprehensive hostname validation, ensuring that values conform to
    # DNS standards for hostnames. It supports constraints on the domain structure, such as
    # top-level domain validation and hostname pattern matching.
    #
    # Key features:
    # - RFC-compliant hostname validation
    # - Maximum length enforcement (253 characters)
    # - ASCII character set requirement
    # - Validation of allowed or disallowed hostnames and TLDs
    #
    # @example Basic usage
    #   type = HostNameType.new
    #   type.validate("example.com") # => true
    #   type.validate("invalid_host") # => false
    #
    # @example With domain constraints
    #   type = HostNameType.new
    #     .having_top_level_domain("com", "org")
    #
    # @example With hostname inclusion/exclusion
    #   type = HostNameType.new
    #     .having_hostname("example.com")
    #     .not_having_hostname("forbidden.com")
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class HostnameType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::StringBehavior::MatchingBehavior
      include Behavior::SizableBehavior
      include Behavior::URIBehavior

      RFC_HOSTNAME_REGEXP = /\A
        [a-zA-Z0-9]                                   # Start with an alphanumeric character
        (?:                                           # Begin optional group for the rest of the segment
          [a-zA-Z0-9-]{0,61}                          # Allow up to 61 characters (letters, digits, hyphens)
          [a-zA-Z0-9]                                 # End segment with an alphanumeric character
        )?                                            # The group is optional
        (?:                                           # Begin optional group for additional domain segments
          \.                                          # Segment must start with a dot
          [a-zA-Z0-9]                                 # Alphanumeric character at the start of the new segment
          (?:                                         # Optional group for segment body
            [a-zA-Z0-9-]{0,61}                        # Allow up to 61 characters (letters, digits, hyphens)
            [a-zA-Z0-9]                               # End segment with an alphanumeric character
          )?                                          # End optional segment body
        )*                                            # Allow zero or more additional segments
      \z/x #: Regexp

      # Core hostname constraints based on RFC standards
      intrinsically_constrain :self, :type, String, abort_on_failure: true, description: :not_described
      intrinsically_constrain :self, :match_pattern, RFC_HOSTNAME_REGEXP, description: :not_described
      intrinsically_constrain :length, :range, { maximum: 253 }, description: :not_described, concerning: :size
      intrinsically_constrain :self, :character_set, :ascii, description: :not_described

      # Constrain hostname to allowed hostnames
      #
      # Creates a constraint ensuring the hostname matches one of the specified hostnames.
      # This is useful for restricting to specific domains.
      #
      # @example
      #   type.having_hostname("example.com", "company.com")
      #   type.validate("example.com") # => true
      #   type.validate("other.com")   # => false
      #
      # @param hostnames [Array<String>] List of allowed hostnames
      # @return [self] self for method chaining
      # @rbs (*String hostnames) -> self
      def matching(*hostnames)
        pattern = /\A(?:#{hostnames.map { |h| Regexp.escape(h) }.join('|')})\z/i
        constrain :self, :match_pattern, pattern, concerning: :inclusion
      end
      alias allowing matching

      # Constrain hostname to exclude specific hostnames
      #
      # Ensures the hostname does not match any of the specified hostnames. Useful for blacklisting.
      #
      # @example
      #   type.not_having_hostname("forbidden.com")
      #   type.validate("allowed.com") # => true
      #   type.validate("forbidden.com") # => false
      #
      # @param hostnames [Array<String>] List of forbidden hostnames
      # @return [self] self for method chaining
      # @rbs (*String hostnames) -> self
      def not_matching(*hostnames)
        pattern = /\A(?:#{hostnames.map { |h| Regexp.escape(h) }.join('|')})\z/i
        hostname_pattern = @constraints.prepare :self, :match_pattern, pattern
        constrain :self, :not, hostname_pattern, concerning: :hostname_exclusion
      end
      alias forbidding not_matching
    end
  end
end
