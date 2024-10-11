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
end
