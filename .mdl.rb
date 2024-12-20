# frozen_string_literal: true

require 'yaml'
config = YAML.load_file(File.expand_path('.markdownlint.yml', __dir__), symbolize_names: true)

all

config.except(:default).each_pair do |rule_id, options|
  options = options.transform_values do |value|
    value.is_a?(Array) ? value.join(',') : value
  end

  rule(rule_id.to_s, **options)
end
