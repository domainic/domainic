# frozen_string_literal: true

require 'domainic/type/description/interpolator/transformer'

module Domainic
  module Type
    class Description
      # @since 0.1.0
      module Interpolator
        class << self
          # @rbs (String template, **untyped variables) -> String
          def interpolate(template, **variables)
            result = template.dup
            start_index = 0

            while (start_marker = result.index('%{', start_index))
              end_marker = result.index('}', start_marker)
              break unless end_marker

              value = resolve_placeholder!(result[start_marker + 2...end_marker] || '', variables)
              result[start_marker..end_marker] = value
              start_index = start_marker + value.length
            end

            result
          end

          private

          # @rbs (Array[String] path, untyped variables) -> String?
          def parse_variable_path(path, variables)
            key, transform = path.last.split('~')
            value = variables.dig(*path.slice(0, path.size - 1)&.map(&:to_sym), key&.to_sym)
            return if value.nil?

            transform.nil? ? value : Transformer[transform.to_sym].call(value)
          end

          # @rbs (String path, untyped variables) -> String
          def resolve_placeholder!(path, variables)
            value = parse_variable_path(path.split(':'), variables)
            raise KeyError, "Missing interpolation value for %{#{path}}" if value.nil?

            value.to_s
          end
        end
      end
    end
  end
end
