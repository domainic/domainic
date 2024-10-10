# frozen_string_literal: true

require 'bundler/setup'
require 'pathname'

def gem_directories_with_gemspec
  Dir.glob('*').select do |dir|
    File.directory?(dir) && Dir.glob("#{dir}/*.gemspec").any?
  end
end

gem_paths = gem_directories_with_gemspec.select do |gem_dir|
  ARGV.any? do |arg|
    arg.start_with?(gem_dir) ||
      arg.start_with?(File.join(Dir.getwd, gem_dir)) ||
      arg.start_with?(File.join('.', gem_dir))
  end
end

gem_paths.each do |gem_path|
  spec_dir = Pathname.new(gem_path).join('spec')
  $LOAD_PATH << spec_dir.to_s if spec_dir.exist? && !$LOAD_PATH.include?(spec_dir.to_s)

  spec_helper = spec_dir.join('spec_helper.rb')
  load spec_helper.to_s if spec_helper.exist?
end
