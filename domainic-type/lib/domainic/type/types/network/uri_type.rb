# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/string_behavior/matching_behavior'
require 'domainic/type/behavior/sizable_behavior'
require 'domainic/type/behavior/uri_behavior'
require 'domainic/type/types/network/hostname_type'
require 'uri'

module Domainic
  module Type
    # A type for validating URIs according to RFC 3986 standards
    #
    # This type provides comprehensive URI validation, ensuring that values conform to
    # standard URI syntax. It supports constraints on components like the scheme, hostname,
    # path, and query string.
    #
    # Key features:
    # - RFC-compliant URI validation
    # - Scheme, hostname, path, and query validation
    # - Maximum length enforcement
    # - ASCII character set requirement
    #
    # @example Basic usage
    #   type = UriType.new
    #   type.validate("https://example.com/path?query=1") # => true
    #   type.validate("not-a-uri") # => false
    #
    # @example With scheme constraints
    #   type = UriType.new
    #     .having_scheme("http", "https")
    #
    # @example With hostname and path constraints
    #   type = UriType.new
    #     .having_hostname("example.com")
    #     .matching_path(/^\/[a-z]+$/)
    #
    # @example With maximum length
    #   type = UriType.new
    #     .having_maximum_size(2000)
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class URIType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::StringBehavior::MatchingBehavior
      include Behavior::SizableBehavior
      include Behavior::URIBehavior

      URI_REGEXP = /\A#{URI::DEFAULT_PARSER.make_regexp}\z/ #: Regexp

      # Core URI constraints based on RFC standards
      intrinsically_constrain :self, :type, String, abort_on_failure: true, description: :not_described
      intrinsically_constrain :self, :match_pattern, URI_REGEXP, description: :not_described
      intrinsically_constrain :self, :character_set, :ascii, description: :not_described

      # Constrain URI hostname to allowed values
      #
      # Uses `HostnameType` to validate the hostname part of the URI.
      #
      # @example
      #   type.having_hostname("example.com")
      #   type.validate("https://example.com")  # => true
      #   type.validate("https://other.com")    # => false
      #
      # @param hostnames [Array<String>] List of allowed hostnames
      # @return [self] self for method chaining
      # @rbs (*String hostnames) -> self
      def having_hostname(*hostnames)
        hostname_type = HostnameType.new(matching: hostnames)
        constrain :self, :type, hostname_type,
                  coerce_with: lambda { |value|
                    begin
                      URI.parse(value).host
                    rescue StandardError
                      nil
                    end
                  }, concerning: :hostname_inclusion
      end
      alias allowing_hostname having_hostname
      alias host having_hostname
      alias hostname having_hostname
      alias with_hostname having_hostname

      # Constrain URI path to match any of the specified patterns
      #
      # Ensures that the path part of the URI matches at least one of the given patterns.
      #
      # @example
      #   type.having_path(/^\/[a-z]+$/, /^\/api\/v\d+/)
      #   type.validate("https://example.com/path") # => true
      #   type.validate("https://example.com/api/v1") # => true
      #   type.validate("https://example.com/123")  # => false
      #
      # @param patterns [Array<Regexp>] Patterns the path must match
      # @return [self] self for method chaining
      # @rbs (*String | Regexp patterns) -> self
      def having_path(*patterns)
        patterns = patterns.map { |p| p.is_a?(String) ? Regexp.new(p) : p }
        combined_pattern = Regexp.union(patterns)
        constrain :self, :match_pattern, combined_pattern,
                  coerce_with: lambda { |value|
                    begin
                      URI.parse(value).path
                    rescue StandardError
                      nil
                    end
                  }, concerning: :path_inclusion
      end
      alias allowing_path having_path
      alias with_path having_path

      # Constrain URI scheme to specific values
      #
      # Ensures that the scheme part of the URI matches one of the specified schemes.
      #
      # @example
      #   type.having_scheme("http", "https")
      #   type.validate("https://example.com") # => true
      #   type.validate("ftp://example.com")   # => false
      #
      # @param schemes [Array<String>] List of allowed schemes
      # @return [self] self for method chaining
      # @rbs (*String schemes) -> self
      def having_scheme(*schemes)
        included_schemes = schemes.map { |scheme| @constraints.prepare :self, :inclusion, scheme.downcase }
        constrain :self, :or, included_schemes,
                  coerce_with: lambda { |value|
                    begin
                      URI.parse(value).scheme&.downcase
                    rescue URI::InvalidURIError
                      nil
                    end
                  }, concerning: :scheme_inclusion
      end
      alias allowing_scheme having_scheme
      alias scheme having_scheme

      # Constrain URI hostname to exclude specific values
      #
      # Uses `HostnameType` to blacklist hostnames.
      #
      # @example
      #   type.not_having_hostname("forbidden.com")
      #   type.validate("https://allowed.com")   # => true
      #   type.validate("https://forbidden.com") # => false
      #
      # @param hostnames [Array<String>] List of forbidden hostnames
      # @return [self] self for method chaining
      # @rbs (*String hostnames) -> self
      def not_having_hostname(*hostnames)
        hostname_type = HostnameType.new(not_matching: hostnames)
        constrain :self, :type, hostname_type,
                  coerce_with: lambda { |value|
                    begin
                      URI.parse(value).host
                    rescue StandardError
                      nil
                    end
                  }, concerning: :hostname_exclusion
      end
      alias forbidding_hostname not_having_hostname
      alias not_host not_having_hostname
      alias not_hostname not_having_hostname

      # Constrain URI path to exclude any of the specified patterns
      #
      # Ensures that the path part of the URI does not match any of the given patterns.
      #
      # @example
      #   type.not_having_path(/^\/admin/, /^\/private/)
      #   type.validate("https://example.com/user") # => true
      #   type.validate("https://example.com/admin") # => false
      #   type.validate("https://example.com/private") # => false
      #
      # @param patterns [Array<Regexp>] Patterns the path must not match
      # @return [self] self for method chaining
      # @rbs (*String | Regexp patterns) -> self
      def not_having_path(*patterns)
        patterns = patterns.map { |p| p.is_a?(String) ? Regexp.new(p) : p }
        combined_pattern = Regexp.union(patterns)
        path_pattern = @constraints.prepare :self, :match_pattern, combined_pattern,
                                            coerce_with: lambda { |value|
                                              begin
                                                URI.parse(value).path
                                              rescue StandardError
                                                nil
                                              end
                                            }
        constrain :self, :not, path_pattern, concerning: :path_exclusion
      end
      alias forbidding_path not_having_path
      alias not_allowing_path not_having_path

      # Constrain URI scheme to exclude specific values
      #
      # Ensures that the scheme part of the URI does not match the specified schemes.
      #
      # @example
      #   type.not_having_scheme("ftp")
      #   type.validate("https://example.com") # => true
      #   type.validate("ftp://example.com")   # => false
      #
      # @param schemes [Array<String>] List of forbidden schemes
      # @return [self] self for method chaining
      # @rbs (*String schemes) -> self
      def not_having_scheme(*schemes)
        included_schemes = schemes.map { |scheme| @constraints.prepare :self, :inclusion, scheme.downcase }
        constrain :self, :nor, included_schemes,
                  coerce_with: lambda { |value|
                    begin
                      URI.parse(value).scheme&.downcase
                    rescue URI::InvalidURIError
                      nil
                    end
                  }, concerning: :scheme_inclusion
      end
      alias forbidding_scheme not_having_scheme
      alias not_allowing_scheme not_having_scheme
    end
  end
end
