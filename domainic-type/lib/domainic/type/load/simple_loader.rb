# frozen_string_literal: true

module Domainic
  module Type
    module Load
      # @since 0.1.0
      class SimpleLoader
        attr_reader :aliases, :constant, :groups, :name

        def initialize(constant:, name:, require_path:, aliases: [], groups: [])
          @aliases = aliases.map(&:to_sym)
          @constant = constant
          @groups = groups.map(&:to_sym)
          @name = name.to_sym
          @require_path = require_path
        end

        def aliased_as?(name)
          @aliases.include?(name.to_sym)
        end

        def in_group?(group)
          @groups.include?(group.to_sym)
        end

        def load
          return true if loaded?

          require @require_path
        end

        def loaded?
          Object.const_defined?(@constant)
        end
      end
    end
  end
end
