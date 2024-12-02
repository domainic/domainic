# frozen_string_literal: true

module Domainic
  module Attributer
    # A singleton object representing an undefined value.
    #
    # This object is used internally to differentiate between an attribute that has been set to `nil`
    # and an attribute that has not been set at all (i.e., is undefined).
    #
    # @!visibility private
    # @since 0.1.0
    Undefined = Object.new.tap do |undefined|
      # Prevents duplication of the Undefined object.
      #
      # @return [self] returns itself since it's a singleton
      # @rbs (**untyped options) -> self
      def undefined.clone(**)
        self
      end

      # Prevents duplication of the Undefined object.
      #
      # @return [self] returns itself since it's a singleton
      # @rbs () -> self
      def undefined.dup
        self
      end

      # Provides a string representation of the Undefined object.
      #
      # @return [String] the string 'Undefined'
      # @rbs () -> String
      def undefined.inspect
        to_s
      end

      # Returns the string 'Undefined'.
      #
      # @return [String] the string 'Undefined'
      # @rbs () -> String
      def undefined.to_s
        'Undefined'
      end
    end.freeze #: Object
  end
end
