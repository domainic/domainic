# frozen_string_literal: true

require 'domainic/type/behavior'
require 'domainic/type/behavior/date_time_behavior'

module Domainic
  module Type
    # A type for validating and constraining strings to match various datetime formats.
    #
    # This class includes behaviors for handling datetime constraints and ensures that
    # a string matches one of the predefined datetime formats (e.g., ISO 8601, RFC2822).
    #
    # @example Validating American format
    #   type = Domainic::Type::DateTimeStringType.new
    #   type.having_american_format.validate!("01/31/2024")
    #
    # @example Validating ISO 8601 format
    #   type = Domainic::Type::DateTimeStringType.new
    #   type.having_iso8601_format.validate!("2024-01-01T12:00:00Z")
    #
    # @example Validating RFC2822 format
    #   type = Domainic::Type::DateTimeStringType.new
    #   type.having_rfc2822_format.validate!("Thu, 31 Jan 2024 13:30:00 +0000")
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    class DateTimeStringType
      # @rbs! extend Behavior::ClassMethods

      include Behavior
      include Behavior::DateTimeBehavior

      # The `Format` module provides a set of regular expressions for validating
      # various datetime formats, including ISO 8601, RFC2822, American, European,
      # full month names, abbreviated month names, and 12-hour clock formats.
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      module Format
        # Matches ISO 8601 datetime formats, including:
        # - `2024-01-01T12:00:00.000+00:00`
        # - `2024-01-01T12:00:00+00:00`
        # - `2024-01-01T12:00:00.000`
        # - `2024-01-01T12:00:00`
        # - `20240101T120000+0000` (basic format)
        # @return [Regexp]
        ISO8601 = /\A\d{4}-\d{2}-\d{2}(?:T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[-+]\d{2}:?\d{2})?)?\z/ #: Regexp

        # Matches RFC2822 datetime formats, including:
        # - `Thu, 31 Jan 2024 13:30:00 +0000`
        # - `31 Jan 2024 13:30:00 +0000`
        # @return [Regexp]
        RFC2822 = /\A
          (?:                                                                     # Optional day of the week
            (?:Mon|Tue|Wed|Thu|Fri|Sat|Sun),\s+
          )?
          \d{1,2}\s+                                                              # Day of the month
          (?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+                  # Month
          \d{2,4}\s+                                                              # Year
          \d{2}:\d{2}                                                             # Time in HH:MM
          (?::\d{2})?                                                             # Optional seconds
          \s+                                                                     # Space
          (?:                                                                     # Time zone
            [+-]\d{4} |                                                           # Offset (e.g., +0000)
            GMT | UTC                                                             # Literal GMT or UTC
          )
        \z/x #: Regexp

        # Matches American-style dates with optional time in 12-hour or 24-hour formats, including:
        # - `01/31/2024`
        # - `01/31/2024 12:30:00`
        # - `01/31/2024 12:30 PM`
        # @return [Regexp]
        AMERICAN = %r{\A\d{1,2}/\d{1,2}/\d{2,4}(?: \d{1,2}:\d{1,2}(?::\d{1,2})?(?:\s*[AaPp][Mm])?)?\z} #: Regexp

        # Matches European-style dates with optional time in 24-hour format, including:
        # - `31.01.2024`
        # - `31.01.2024 12:30:00`
        # @return [Regexp]
        EUROPEAN = /\A\d{1,2}\.\d{1,2}\.\d{2,4}(?: \d{1,2}:\d{2}(?::\d{2})?)?\z/ #: Regexp

        # Matches datetime formats with full month names, including:
        # - `January 31, 2024 12:00:00`
        # - `January 31, 2024 12:00`
        # @return [Regexp]
        FULL_MONTH_NAME = /\A
          (?:                                                                      # Full month name
            (?:January|February|March|April|May|June|July|August|September|October|November|December)
          )\s+\d{1,2},\s+\d{4}(?:\s+\d{1,2}:\d{2}(?::\d{2})?)?
        \z/x #: Regexp

        # Matches datetime formats with abbreviated month names, including:
        # - `Jan 31, 2024 12:00:00`
        # - `Jan 31, 2024 12:00`
        # @return [Regexp]
        ABBREVIATED_MONTH_NAME = /\A
          \d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec),\s+\d{4}(?:\s+\d{1,2}:\d{2}(?::\d{2})?)?
        \z/x #: Regexp

        # Matches datetime formats using a 12-hour clock with AM/PM, including:
        # - `2024-01-01 01:30:00 PM`
        # - `2024-01-01 01:30 PM`
        # @return [Regexp]
        TWELVE_HOUR_FORMAT = /\A\d{4}-\d{2}-\d{2}\s+\d{1,2}:\d{2}(?::\d{2})?\s+[APap][Mm]\z/x #: Regexp
      end
      private_constant :Format

      intrinsically_constrain :self, :type, String, abort_on_failure: true, description: :not_described
      intrinsically_constrain :self, :match_pattern,
                              Regexp.union(Format.constants.map { |name| Format.const_get(name) }),
                              abort_on_failure: true, concerning: :format, description: :not_described

      # Constrain the type to match American-style datetime formats.
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def having_american_format
        constrain :self, :match_pattern, Format::AMERICAN, concerning: :format
      end
      alias american having_american_format
      alias having_us_format having_american_format
      alias us_format having_american_format

      # Constrain the type to match European-style datetime formats.
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def having_european_format
        constrain :self, :match_pattern, Format::EUROPEAN, concerning: :format
      end
      alias european having_european_format
      alias having_eu_format having_european_format
      alias eu_format having_european_format

      # Constrain the type to match ISO 8601 datetime formats.
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def having_iso8601_format
        constrain :self, :match_pattern, Format::ISO8601, concerning: :format
      end
      alias iso8601 having_iso8601_format
      alias iso8601_format having_iso8601_format

      # Constrain the type to match RFC2822 datetime formats.
      #
      # @return [self] self for method chaining
      # @rbs () -> self
      def having_rfc2822_format
        constrain :self, :match_pattern, Format::RFC2822, concerning: :format
      end
      alias rfc2822 having_rfc2822_format
      alias rfc2822_format having_rfc2822_format
    end
  end
end
