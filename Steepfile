# frozen_string_literal: true

target :domainic_dev do
  check 'domainic-dev/lib/**/*.rb'
  signature 'domainic-dev/sig/**/*.rbs'

  library 'fileutils'
  library 'pathname'

  configure_code_diagnostics(Steep::Diagnostic::Ruby.strict)
end

target :domainic_type do
  check 'domainic-type/lib/**/*.rb'
  signature 'domainic-type/sig/**/*.rbs'

  configure_code_diagnostics do |config|
    # disable this diagnostic pending the resolution of https://github.com/soutaro/steep/issues/1207
    config[Steep::Diagnostic::Ruby::BlockTypeMismatch] = :hint
  end
end
