# frozen_string_literal: true

require 'domainic/dev'
require 'domainic/dev/gem'
require 'domainic/dev/generator/base_generator'

module Domainic
  module Dev
    module Generator
      # A generator for creating new Domainic gems.
      #
      # This class extends {BaseGenerator} to provide functionality for generating new gems in the Domainic monorepo.
      # It handles creating the gem structure, documentation files, specs, and updating the necessary project files.
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class GemGenerator < BaseGenerator
        # @rbs @constant_name: String
        # @rbs @directory_name: String
        # @rbs @module_name: String
        # @rbs @module_path: String

        argument :name, type: :string # steep:ignore NoMethod
        class_option :summary, type: :string, # steep:ignore NoMethod
                               desc: 'The summary of the gem.', default: 'TODO: EDIT ME'

        # @rbs! def name: () -> String

        # Initialize a new GemGenerator instance.
        #
        # @param arguments [Array<Object>] the generator arguments
        # @param options [Array<Object>] additional options
        # @return [void]
        # @rbs (Array[untyped], *untyped) -> void
        def initialize(arguments, *options)
          super
          assign_names!(name)
        end

        # Create the gem's CHANGELOG file.
        #
        # @return [void]
        # @rbs () -> void
        def create_changelog
          template('CHANGELOG.md.erb', "#{name}/CHANGELOG.md") # steep:ignore NoMethod
        end

        # Create the gem's gemspec file.
        #
        # @return [void]
        # @rbs () -> void
        def create_gemspec
          template('gemspec.erb', "#{name}/#{name}.gemspec") # steep:ignore NoMethod
        end

        # Create the gem's gitignore file.
        #
        # @return [void]
        # @rbs () -> void
        def create_gitignore
          template('.gitignore', "#{name}/.gitignore") # steep:ignore NoMethod
        end

        # Create the gem's LICENSE file.
        #
        # @return [void]
        # @rbs () -> void
        def create_license
          template('LICENSE', "#{name}/LICENSE") # steep:ignore NoMethod
        end

        # Create the module's main library file.
        #
        # @return [void]
        # @rbs () -> void
        def create_module_lib_file
          dest = [name, 'lib', directory_name, "#{file_name}.rb"].join('/')
          template('lib/module.rb.erb', dest) # steep:ignore NoMethod
        end

        # Create the gem's README file.
        #
        # @return [void]
        # @rbs () -> void
        def create_readme
          template('README.md.erb', "#{name}/README.md") # steep:ignore NoMethod
        end

        # Create the root library file for gems with dashes in their name.
        #
        # @return [void]
        # @rbs () -> void
        def create_root_lib_file
          return unless name.include?('-')

          template('lib/root.rb.erb', "#{name}/lib/#{name}.rb") # steep:ignore NoMethod
        end

        # Create the root spec file.
        #
        # @return [void]
        # @rbs () -> void
        def create_root_spec_file
          dest = [name, 'spec', directory_name, "#{file_name}_spec.rb"].join('/')
          template('spec/spec.rb.erb', dest) # steep:ignore NoMethod
        end

        # Create the signature manifest file
        #
        # @return [void]
        # @rbs () -> void
        def create_signature_manifest
          dest = [name, 'sig', 'manifest.yaml'].join('/')
          template('sig/manifest.yaml.erb', dest) # steep:ignore NoMethod
        end

        # Create the gem's spec_helper file.
        #
        # @return [void]
        # @rbs () -> void
        def create_spec_helper
          template('spec/spec_helper.rb.erb', "#{name}/spec/spec_helper.rb") # steep:ignore NoMethod
        end

        # Create the gem's .yardopts file.
        #
        # @return [void]
        # @rbs () -> void
        def create_yardopts
          template('.yardopts', "#{name}/.yardopts") # steep:ignore NoMethod
        end

        # Generate RBS signatures for the new gem.
        #
        # @return [void]
        # @rbs () -> void
        def generate_signatures
          system 'bin/dev', 'generate', 'signatures', name
        end

        # Update the Domainic gemspec with the new gem dependency.
        #
        # @return [void]
        # @rbs () -> void
        def update_domainic_gemspec
          gemspec, lines, dependencies = domainic_gemspec_and_dependencies
          # @type var gemspec: Pathname
          # @type var lines: Array[String]
          # @type var dependencies: Array[String]
          insert_index = domainic_dependencies_insert_index(lines)
          updated_lines = lines.reject { |line| line.match(/^\s*spec\.add_dependency\s+/) }
          updated_lines.insert(insert_index, dependencies.join)
          gemspec.write(updated_lines.join)
        end

        # Update the Steepfile with the new gem's type checking configuration.
        #
        # @return [void]
        # @rbs () -> void
        def update_steepfile
          steepfile, lines, check_lines = steepfile_and_check_lines
          # @type var steepfile: Pathname
          # @type var lines: Array[String]
          # @type var check_lines: Array[String]
          insert_index = lines.find_index { |line| !line.include?('#') && line.include?('check') } || lines.size
          updated_lines = lines.reject { |line| !line.include?('#') && line.include?('check') }
          updated_lines.insert(insert_index, check_lines.join)
          steepfile.write(updated_lines.join)
        end

        private

        attr_reader :module_name #: String
        attr_reader :module_path #: String

        # Assign module name and path from the gem name.
        #
        # @param name [String] the gem name
        # @return [void]
        # @rbs (String name) -> void
        def assign_names!(name)
          @module_name = name.split('-').map { |part| part.split('_').map(&:capitalize).join }.join('::')
          @module_path = module_name.split('::').map do |part|
            part.gsub(/([a-z\d])([A-Z])/, '\1_\2').gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').downcase
          end.join('/')
        end

        # Get the constant name for the gem.
        #
        # @return [String] the constant name
        # @rbs () -> String
        def constant_name
          @constant_name ||= name.split(/[-_]/).map(&:upcase).join('_')
        end

        # Get the directory name for the module.
        #
        # @return [String] the directory name
        # @rbs () -> String
        def directory_name
          @directory_name = module_path.split('/').reject { |part| part == file_name }.join('/')
        end

        # Find the insertion index for dependencies in the Domainic gemspec.
        #
        # @param lines [Array<String>] the gemspec lines
        # @return [Integer] the insertion index
        # @rbs (Array[String]) -> Integer
        def domainic_dependencies_insert_index(lines)
          lines.find_index { |line| line.match(/^\s*spec\.add_dependency\s+/) } ||
            lines.rindex { |line| line.strip == 'end' } ||
            lines.size
        end

        # Get the Domainic gemspec and its dependencies.
        #
        # @return [Array<Array(Pathname, Array<String>, Array<String>)>] the gemspec, lines, and dependencies
        # @raise [RuntimeError] if the Domainic gem cannot be found
        # @rbs () -> Array[Pathname | Array[String]]
        def domainic_gemspec_and_dependencies
          gem = Domainic::Dev::Gem.find('domainic')
          raise 'Unable to find the Domainic gem' unless gem

          gemspec = gem.paths.gemspec
          lines = gemspec.readlines
          dependencies = lines.grep(/^\s*spec\.add_dependency\s+/)
                              .push("  spec.add_dependency '#{name}', '>= 0.1'\n")
                              .uniq
                              .sort
          [gemspec, lines, dependencies]
        end

        # Get the file name from the module path.
        #
        # @return [String, nil] the file name
        # @rbs () -> String?
        def file_name
          module_path.split('/').pop
        end

        # Get the Steepfile and its check lines.
        #
        # @return [Array<Array(Pathname, Array<String>, Array<String>)>] the steepfile, lines, and check lines
        # @raise [RuntimeError] if the Steepfile cannot be found
        # @rbs () -> Array[Pathname | Array[String]]
        def steepfile_and_check_lines
          steepfile = Domainic::Dev.root.join('Steepfile')
          raise 'Unable to find steepfile' unless steepfile.exist?

          lines = steepfile.readlines
          check_lines = lines.select { |line| !line.include?('#') && line.include?('check') }
                             .push("  check '#{name}/lib'\n")
                             .uniq
                             .sort
          [steepfile, lines, check_lines]
        end
      end
    end
  end
end
