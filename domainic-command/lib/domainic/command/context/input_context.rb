# frozen_string_literal: true

require 'domainic/command/context/behavior'

module Domainic
  module Command
    module Context
      # @since 0.1.0
      class InputContext
        # @rbs! extend Behavior::ClassMethods

        include Behavior

        # @rbs (
        #   String | Symbol name,
        #   ?(String | Attribute::type_validator)? type_validator_or_description,
        #   ?(String | Attribute::type_validator)? description_or_type_validator,
        #   ?default: untyped?,
        #   ?default_generator: untyped?,
        #   ?default_value: untyped?,
        #   ?desc: String?,
        #   ?description: String?,
        #   ?required: bool?,
        #   ?type: type_validator?
        #   ) -> void
        def self.argument(...) = attribute(...)
      end
    end
  end
end
