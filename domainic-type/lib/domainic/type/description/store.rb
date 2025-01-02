# frozen_string_literal: true

require 'yaml'

module Domainic
  module Type
    class Description
      # @since 0.1.0
      module Store
        CONFIG_FILE = File.expand_path('../config/descriptions.yml', File.dirname(__FILE__)).freeze #: String
        private_constant :CONFIG_FILE

        class << self
          # @rbs self.@lookup: Hash[Symbol, untyped]

          # @rbs (String key_string) -> String
          def template(key_string)
            keys = key_string.split('.').map(&:to_sym)
            template = lookup.dig(*keys)
            template = template[:default] if template.is_a?(Hash)
            raise ArgumentError, "Description not found for key: #{key_string}" if template.nil?

            template
          end

          private

          # @rbs () -> Hash[Symbol, untyped]
          def lookup
            @lookup ||= begin
              options = { aliases: true, symbolize_names: true }
              YAML.load_file(CONFIG_FILE, **options)[:descriptions].freeze
            end
          end
        end
      end
    end
  end
end
