# frozen_string_literal: true

module Domainic
  module Command
    class Result
      # A flexible container for managing and formatting command errors. The ErrorSet provides a consistent
      # interface for working with errors from various sources including simple strings, arrays, hashes,
      # standard errors, and objects implementing a compatible `to_h` interface (like ActiveModel::Errors).
      #
      # @example Basic usage
      #   errors = ErrorSet.new("Something went wrong")
      #   errors[:generic] #=> ["Something went wrong"]
      #   errors.full_messages #=> ["generic Something went wrong"]
      #
      # @example Hash-style errors
      #   errors = ErrorSet.new(
      #     name: "can't be blank",
      #     email: ["invalid format", "already taken"]
      #   )
      #   errors[:name] #=> ["can't be blank"]
      #   errors[:email] #=> ["invalid format", "already taken"]
      #
      # @example ActiveModel compatibility
      #   user = User.new
      #   user.valid? #=> false
      #   errors = ErrorSet.new(user.errors)
      #   errors[:email] #=> ["can't be blank"]
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class ErrorSet
        # @rbs @lookup: Hash[Symbol, Array[String]]

        # Creates a new ErrorSet instance
        #
        # @param errors [String, Array, Hash, StandardError, #to_h, nil] The errors to parse
        #
        # @raise [ArgumentError] If the errors cannot be parsed
        # @return [ErrorSet] the new ErrorSet instance
        # @rbs (?untyped? errors) -> void
        def initialize(errors = nil)
          @lookup = Parser.new(errors).parse!
        end

        # Retrieves error messages for a specific key
        #
        # @param key [String, Symbol] The error key to lookup
        # @return [Array<String>, nil] The error messages for the key
        # @rbs (String | Symbol key) -> Array[String]?
        def [](key)
          @lookup[key.to_sym]
        end

        # Adds a new error message for a specific key
        #
        # @param key [String, Symbol] The error key
        # @param message [String, Array<String>] The error message(s)
        #
        # @return [void]
        # @rbs (String | Symbol key, Array[String] | String message) -> void
        def add(key, message)
          key = key.to_sym
          @lookup[key] ||= []
          @lookup[key].concat(Array(message)) # steep:ignore ArgumentTypeMismatch
        end

        # Clear all errors from the set
        #
        # @return [void]
        # @rbs () -> void
        def clear
          @lookup = {}
        end

        # Check if the error set is empty
        #
        # @return [Boolean] `true` if the error set is empty, `false` otherwise
        # @rbs () -> bool
        def empty?
          @lookup.empty?
        end

        # Returns all error messages with their keys
        #
        # @return [Array<String>] All error messages prefixed with their keys
        # @rbs () -> Array[String]
        def full_messages
          @lookup.each_with_object([]) do |(key, messages), result|
            result.concat(messages.map { |message| "#{key} #{message}" })
          end
        end
        alias to_a full_messages
        alias to_array full_messages
        alias to_ary full_messages

        # Returns a hash of all error messages
        #
        # @return [Hash{Symbol => Array<String>}] All error messages grouped by key
        # @rbs () -> Hash[Symbol, Array[String]]
        def messages
          @lookup.dup.freeze
        end
        alias to_h messages
        alias to_hash messages

        # A utility class for parsing various error formats into a consistent structure
        #
        # @!visibility private
        # @api private
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class Parser
          # Mapping of classes to their parsing strategy methods
          #
          # @return [Hash{Class, Module => Symbol}]
          TYPE_STRATEGIES = {
            Array => :parse_array,
            Hash => :parse_hash,
            String => :parse_generic_error,
            StandardError => :parse_standard_error
          }.freeze #: Hash[Class | Module, Symbol]

          # Mapping of method names to their parsing strategy methods
          #
          # @return [Hash{Symbol => Symbol}]
          RESPOND_TO_STRATEGIES = { to_h: :parse_to_h }.freeze #: Hash[Symbol, Symbol]

          # Create a new Parser instance
          #
          # @param errors [Object] the errors to parse
          #
          # @return [Parser] the new Parser instance
          # @rbs (untyped errors) -> void
          def initialize(errors)
            @errors = errors
            @parsed = {}
          end

          # Parses the errors into a consistent format
          #
          # @raise [ArgumentError] If the errors cannot be parsed
          # @return [Hash{Symbol => Array<String>}]
          # @rbs () -> Hash[Symbol, Array[String]]
          def parse!
            parse_errors!
            @parsed.transform_values { |errors| Array(errors) }
          end

          private

          # Parses an array of errors into the generic error category
          #
          # @param errors [Array<String, StandardError>] Array of errors to parse
          #
          # @raise [ArgumentError] If any array element is not a String or StandardError
          # @return [void]
          # @rbs (Array[String | StandardError] errors) -> void
          def parse_array(errors)
            errors.each do |error|
              case error
              when String then parse_generic_error(error)
              when StandardError then parse_standard_error(error)
              else raise_invalid_errors!
              end
            end
          end

          # Determines the appropriate parsing strategy and executes it
          #
          # @raise [ArgumentError] If no valid parsing strategy is found
          # @return [void]
          # @rbs () -> void
          def parse_errors!
            return if @errors.nil?

            TYPE_STRATEGIES.each_pair { |type, strategy| return send(strategy, @errors) if @errors.is_a?(type) }

            RESPOND_TO_STRATEGIES.each_pair do |method, strategy|
              return send(strategy, @errors) if @errors.respond_to?(method)
            end

            raise_invalid_errors!
          end

          # Parses a string or array of strings into the generic error category
          #
          # @param errors [String, Array<String>] The error(s) to parse
          #
          # @return [void]
          # @rbs (Array[String] | String errors) -> void
          def parse_generic_error(errors)
            @parsed[:generic] ||= []
            @parsed[:generic].concat(Array(errors))
          end

          # Parses a hash of errors into categorized messages
          #
          # @param errors [Hash{String, Symbol => Array<String>, String}] Hash of errors
          #
          # @raise [ArgumentError] If any value cannot be parsed
          # @return [void]
          # @rbs (Hash[String | Symbol, Array[StandardError] | Array[String] | StandardError | String] errors) -> void
          def parse_hash(errors)
            @parsed.merge!(errors.transform_keys(&:to_sym).transform_values { |value| parse_hash_value(value) })
          end

          # Parses a single value from a hash array
          #
          # @param value [String, StandardError] The value to parse
          #
          # @raise [ArgumentError] If the value is neither a String nor StandardError
          # @return [String] The parsed error message
          # @rbs (String | StandardError value) -> String
          def parse_hash_array_value(value)
            case value
            when String then value
            when StandardError then value.message
            else raise_invalid_errors!
            end
          end

          # Parses a value from a hash of errors
          #
          # @param value [String, StandardError, Array<String, StandardError>] The value to parse
          #
          # @raise [ArgumentError] If the value cannot be parsed
          # @return [Array<String>] The parsed error message(s)
          # @rbs (String | StandardError | Array[String | StandardError] value) -> Array[String]
          def parse_hash_value(value)
            case value
            when String then [value]
            when StandardError then [value.message]
            when Array then value.map { |array_value| parse_hash_array_value(array_value) }
            else raise_invalid_errors!
            end
          end

          # Parses a StandardError into the generic error category
          #
          # @param errors [StandardError] The error to parse
          #
          # @return [void]
          # @rbs (StandardError errors) -> void
          def parse_standard_error(errors)
            parse_generic_error(errors.message)
          end

          # Parses an object that responds to to_h
          #
          # @param errors [#to_h] The object to parse
          #
          # @raise [ArgumentError] If the hash cannot be parsed
          # @return [void]
          # @rbs (untyped errors) -> void
          def parse_to_h(errors)
            parse_hash(errors.to_h)
          end

          # Raises an invalid errors exception
          #
          # @raise [ArgumentError] Always raises with an invalid errors message
          # @return [void]
          # @rbs () -> void
          def raise_invalid_errors!
            raise ArgumentError, "invalid errors: #{@errors}"
          end
        end
      end
    end
  end
end
