# frozen_string_literal: true

DOMAINIC_ATTRIBUTER_GEM_VERSION = '0.1.0'
DOMAINIC_ATTRIBUTER_SEMVER = '0.1.0'
DOMAINIC_ATTRIBUTER_REPO_URL = 'https://github.com/domainic/domainic'
DOMAINIC_ATTRIBUTER_HOME_URL = "#{DOMAINIC_ATTRIBUTER_REPO_URL}/tree/domainic-attributer-v" \
                               "#{DOMAINIC_ATTRIBUTER_SEMVER}/domainic-attributer".freeze

Gem::Specification.new do |spec|
  spec.name        = 'domainic-attributer'
  spec.version     = DOMAINIC_ATTRIBUTER_GEM_VERSION
  spec.authors     = ['Aaron Allen']
  spec.email       = ['hello@aaronmallen.me']
  spec.homepage    = DOMAINIC_ATTRIBUTER_HOME_URL
  spec.summary     = 'A toolkit for creating self-documenting, type-safe class attributes with built-in validation, ' \
                     'coercion, and default values.'
  spec.description = 'Your domain objects deserve better than plain old attributes. Level up your DDD game with ' \
                     'powerful, configurable, and well-documented class attributes that actually know what they want ' \
                     'in life!'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.files = Dir.chdir(__dir__) do
    Dir['{lib,sig}/**/*', 'LICENSE', 'README.md', 'CHANGELOG.md'].reject { |f| File.directory?(f) }
  end
  spec.require_paths = ['lib']

  spec.metadata = {
    'bug_tracker_uri' => "#{DOMAINIC_ATTRIBUTER_REPO_URL}/issues",
    'changelog_uri' => "#{DOMAINIC_ATTRIBUTER_REPO_URL}/releases/tag/domainic-attributer-v" \
                       "#{DOMAINIC_ATTRIBUTER_SEMVER}",
    'homepage_uri' => DOMAINIC_ATTRIBUTER_HOME_URL,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => "#{DOMAINIC_ATTRIBUTER_REPO_URL}/tree/domainic-attributer-v" \
                         "#{DOMAINIC_ATTRIBUTER_SEMVER}/domainic-attributer"
  }
end
