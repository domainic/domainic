# frozen_string_literal: true

DOMAINIC_DEV_GEM_VERSION = '0.1.0'
DOMAINIC_DEV_SEMVER = '0.1.0'

Gem::Specification.new do |spec|
  spec.name     = 'domainic-dev'
  spec.version  = DOMAINIC_DEV_GEM_VERSION
  spec.homepage = 'https://github.com/domainic/domainic'
  spec.authors  = ['Aaron Allen']
  spec.email    = ['hello@aaronmallen.me']
  spec.summary  = 'Domainic Development Tools'
  spec.license  = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.files = Dir['README.md', 'LICENSE', 'lib/**/*', 'sig/**/*']
  spec.require_paths = ['lib']

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/domainic/domainic/tree/main/domainic-dev'
  }
end
