# frozen_string_literal: true

module Domainic
  module Type
    module Behavior
      # A module providing URI-based validation behaviors for types.
      #
      # This module extends the base Type::Behavior with methods designed for validating URI-related constraints.
      # It focuses on ensuring URIs conform to specific rules, such as restricting or excluding particular
      # top-level domains (TLDs). These features are useful for scenarios like domain-specific validations
      # or blocking specific domain extensions.
      #
      # Key features:
      # - Top-level domain inclusion constraints
      # - Top-level domain exclusion constraints
      # - Flexible and customizable pattern matching
      # - Consistent interface for defining URI-related constraints
      #
      # @example Basic usage
      #   class MyType
      #     include Domainic::Type::Behavior::URIBehavior
      #
      #     def initialize
      #       super
      #       having_top_level_domain("com", "org")      # Allow only .com and .org
      #       not_having_top_level_domain("test", "dev") # Exclude .test and .dev
      #     end
      #   end
      #
      # @example Method aliases
      #   type.having_top_level_domain("com")      # Allow only .com
      #   type.tld("com")                          # Same as above
      #   type.with_tld("com")                     # Same as above
      #
      #   type.not_having_top_level_domain("test") # Exclude .test
      #   type.not_tld("test")                     # Same as above
      #   type.not_top_level_domain("test")        # Same as above
      #
      # This module provides a consistent interface for working with URIs, ensuring flexibility and
      # extensibility for domain and TLD validation tasks.
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      module URIBehavior
        # Constrain URIBehavior to allowed top-level domains
        #
        # Creates a constraint ensuring the URIBehavior uses one of the specified top-level
        # domains (TLDs). This allows restricting emails to specific TLDs like .com or .org.
        #
        # @example
        #   type.having_top_level_domain("com", "org")
        #   type.validate("example.com")  # => true
        #   type.validate("example.net")  # => false
        #
        # @param top_level_domains [Array<String>] List of allowed TLDs
        # @return [self] self for method chaining
        # @rbs (*String top_level_domains) -> Behavior
        def having_top_level_domain(*top_level_domains)
          pattern = /\.(#{top_level_domains.map { |t| Regexp.escape(t) }.join('|')})\z/i
          # @type self: Object & Behavior
          constrain :self, :match_pattern, pattern, concerning: :top_level_domain_inclusion
        end
        alias allowing_tld having_top_level_domain
        alias allowing_top_level_domain having_top_level_domain
        alias having_tld having_top_level_domain
        alias tld having_top_level_domain
        alias with_tld having_top_level_domain
        alias with_top_level_domain having_top_level_domain

        # Constrain URIBehavior to exclude specific top-level domains
        #
        # Creates a constraint ensuring the email does not use any of the specified
        # top-level domains (TLDs). Useful for blocking certain TLDs.
        #
        # @example
        #   type.not_having_top_level_domain("test")
        #   type.validate("example.com")   # => true
        #   type.validate("example.test")  # => false
        #
        # @param top_level_domains [Array<String>] List of forbidden TLDs
        # @return [self] self for method chaining
        # @rbs (*String top_level_domains) -> Behavior
        def not_having_top_level_domain(*top_level_domains)
          pattern = /\.(#{top_level_domains.map { |t| Regexp.escape(t) }.join('|')})\z/i
          top_level_domains = @constraints.prepare :self, :match_pattern, pattern
          # @type self: Object & Behavior
          constrain :self, :not, top_level_domains, concerning: :top_level_domain_exclusion
        end
        alias forbidding_tld not_having_top_level_domain
        alias forbidding_top_level_domain not_having_top_level_domain
        alias not_having_tld not_having_top_level_domain
        alias not_tld not_having_top_level_domain
        alias not_top_level_domain not_having_top_level_domain
      end
    end
  end
end
