# frozen_string_literal: true

module Domainic
  module Attributer
    # A singleton object representing an undefined value.
    #
    # This object is used throughout Domainic::Attributer to represent values that
    # are explicitly undefined, as opposed to nil which represents the absence of
    # a value. It is immutable and implements custom string representations for
    # debugging purposes.
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    Undefined = Object.new.tap do |undefined|
      # Returns self to prevent cloning.
      #
      # @return [Undefined] self
      def undefined.clone(...)
        self
      end

      # Returns self to prevent duplication.
      #
      # @return [Undefined] self
      def undefined.dup
        self
      end

      # Returns a string representation of the object.
      #
      # @return [String] the string 'Undefined'
      def undefined.inspect
        to_s
      end

      # Converts the object to a string.
      #
      # @return [String] the string 'Undefined'
      def undefined.to_s
        'Undefined'
      end
    end.freeze #: Object
  end
end
