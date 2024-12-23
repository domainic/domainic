# frozen_string_literal: true

module Domainic
  module Type
    # @rbs!
    #   type accessor = :abs | :begin | :chars | :class | :count | :end | :entries | :first | :keys | :last | :length |
    #                   :self | :size | :values

    # A list of valid access methods that can be used to retrieve values for constraint validation.
    # These methods represent common Ruby interfaces for accessing collection sizes, ranges, and values.
    #
    # - :abs                       - For absolute values
    # - :begin, :end               - For Range-like objects
    # - :class                     - For type checking
    # - :count, :length, :size     - For measuring collections
    # - :entries, :chars           - For accessing sequence elements
    # - :first, :last              - For accessing sequence endpoints
    # - :keys, :values             - For Hash-like objects
    # - :self                      - For operating directly on the value
    #
    # @author {https://aaronmallen.me Aaron Allen}
    # @since 0.1.0
    # @return [Array<Symbol>]
    ACCESSORS = %i[
      class
      self
      entries
      chars
      abs
      count
      size
      length
      first
      last
      begin
      end
      keys
      values
    ].freeze #: Array[accessor]
  end
end
