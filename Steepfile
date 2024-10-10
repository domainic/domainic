# frozen_string_literal: true

target :domainic_dev do
  check 'domainic-dev/lib/**/*.rb'
  signature 'domainic-dev/sig/**/*.rbs'

  configure_code_diagnostics(Steep::Diagnostic::Ruby.all_error)
  library 'fileutils'
  library 'pathname'
end
