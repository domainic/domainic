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

  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == File.basename(__FILE__)) || f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/domainic/domainic/tree/main/domainic-dev'
  }
end
