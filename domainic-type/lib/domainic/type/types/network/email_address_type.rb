# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/string_behavior/matching_behavior'
require 'domainic/type/behavior/sizable_behavior'
require 'domainic/type/behavior/uri_behavior'
require 'uri'

module Domainic
  module Type
    # A type for validating email addresses according to RFC standards
    #
    # This type provides comprehensive email address validation following RFC 5321 and 5322
    # standards. It supports constraints on all email components (local part, hostname, TLD)
    # while enforcing basic email requirements like maximum length and character set rules.
    #
    # Key features:
    # - RFC compliant email format validation
    # - Maximum length enforcement (254 characters)
    # - ASCII character set requirement
    # - Hostname and TLD validation
    # - Local part pattern matching
    #
    # @example Basic usage
    #   type = EmailAddressType.new
    #   type.validate("user@example.com")  # => true
    #   type.validate("invalid")           # => false
    #
    # @example With domain constraints
    #   type = EmailAddressType.new
    #     .having_hostname("example.com", "company.com")
    #     .having_top_level_domain("com", "org")
    #
    # @example With local part validation
    #   type = EmailAddressType.new
    #     .having_local_matching(/^[a-z]+$/)
    #     .not_having_local_matching(/^admin/)
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class EmailAddressType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::StringBehavior::MatchingBehavior
      include Behavior::SizableBehavior
      include Behavior::URIBehavior

      # Core email constraints based on RFCs 5321 and 5322
      intrinsically_constrain :self, :type, String, abort_on_failure: true, description: :not_described
      intrinsically_constrain :self, :match_pattern, URI::MailTo::EMAIL_REGEXP, description: :not_described
      intrinsically_constrain :length, :range, { maximum: 254 }, description: :not_described, concerning: :size
      intrinsically_constrain :self, :character_set, :ascii, description: :not_described
      empty = intrinsic_constraints.prepare :self, :emptiness
      intrinsically_constrain :self, :not, empty, description: :not_described

      # Constrain email to allowed hostnames
      #
      # Creates a constraint ensuring the domain part of the email matches one of the
      # specified hostnames. This is useful for restricting emails to specific domains.
      #
      # @example
      #   type.having_hostname("example.com", "company.com")
      #   type.validate("user@example.com")  # => true
      #   type.validate("user@other.com")    # => false
      #
      # @param hostnames [Array<String>] List of allowed hostnames
      # @return [self] self for method chaining
      # @rbs (*String hostnames) -> self
      def having_hostname(*hostnames)
        hostnames = hostnames.map { |h| Regexp.escape(h) }
        pattern = /\A(?:#{hostnames.join('|')})(?:\.[a-z]+)?+\z/i
        constrain :self, :match_pattern, pattern,
                  coerce_with: ->(value) { value.split('@').last }, concerning: :hostname_inclusion
      end
      alias allowing_host having_hostname
      alias allowing_hostname having_hostname
      alias host having_hostname
      alias hostname having_hostname
      alias with_host having_hostname
      alias with_hostname having_hostname

      # Constrain email local part to match pattern
      #
      # Creates a constraint requiring the local part (before @) to match the given pattern.
      # Useful for enforcing username conventions or restrictions.
      #
      # @example
      #   type.having_local_matching(/^[a-z]+$/)
      #   type.validate("user@example.com")    # => true
      #   type.validate("123@example.com")     # => false
      #
      # @param pattern [Regexp] Pattern the local part must match
      # @return [self] self for method chaining
      # @rbs (String | Regexp pattern) -> self
      def having_local_matching(pattern)
        constrain :self, :match_pattern, pattern,
                  coerce_with: ->(value) { value.split('@').first }, concerning: :local_part_inclusion
      end
      alias matching_local having_local_matching
      alias with_local_matching having_local_matching

      # Constrain email to exclude specific hostnames
      #
      # Creates a constraint ensuring the domain part of the email does not match any
      # of the specified hostnames. Useful for blacklisting certain domains.
      #
      # @example
      #   type.not_having_hostname("example.com")
      #   type.validate("user@company.com")    # => true
      #   type.validate("user@example.com")    # => false
      #
      # @param hostnames [Array<String>] List of forbidden hostnames
      # @return [self] self for method chaining
      # @rbs (*String hostnames) -> self
      def not_having_hostname(*hostnames)
        hostnames = hostnames.map { |h| Regexp.escape(h) }
        pattern = /\A(?:#{hostnames.join('|')})(?:\.[a-z]+)?+\z/i
        hostname_pattern = @constraints.prepare :self, :match_pattern, pattern,
                                                coerce_with: ->(value) { value.split('@').last }
        constrain :self, :not, hostname_pattern, concerning: :hostname_exclusion
      end
      alias forbidding_host not_having_hostname
      alias forbidding_hostname not_having_hostname
      alias not_host not_having_hostname
      alias not_hostname not_having_hostname

      # Constrain email local part to not match pattern
      #
      # Creates a constraint ensuring the local part (before @) does not match the given
      # pattern. Useful for preventing certain username patterns.
      #
      # @example
      #   type.not_having_local_matching(/^admin/)
      #   type.validate("user@example.com")     # => true
      #   type.validate("admin@example.com")    # => false
      #
      # @param pattern [Regexp] Pattern the local part must not match
      # @return [self] self for method chaining
      # @rbs (String | Regexp pattern) -> self
      def not_having_local_matching(pattern)
        local_pattern = @constraints.prepare :self, :match_pattern, pattern,
                                             coerce_with: ->(value) { value.split('@').first }
        constrain :self, :not, local_pattern, concerning: :local_part_exclusion
      end
      alias not_matching_local not_having_local_matching
    end
  end
end
