# frozen_string_literal: true

module Domainic
  module Dev
    class CLI < Thor
      # Manage gem versions through the Domainic Dev command line interface
      #
      # @since 0.1.0
      class Version < Thor
        desc 'bump <GEM NAME>', 'Bump a gem version'
        long_desc <<~LONGDESC, wrap: false
          Bump the version of the specified gem.

          If no version type is specified, the patch version will be bumped.

          Examples:

          $ dev version bump domainic-type --major          bump the major version
          $ dev version bump domainic-type --minor          bump the minor version
          $ dev version bump domainic-type --patch          bump the patch version
        LONGDESC
        at_least_one do
          option :major, type: :boolean, default: false
          option :minor, type: :boolean, default: false
          option :patch, type: :boolean, default: false
        end
        def bump(gem_name)
          gem = GemManager.gem(gem_name)
          raise ArgumentError, "Gem '#{gem_name}' not found" unless gem

          method = options.find { |_k, v| v == true }&.first
          raise ArgumentError, "Invalid options: #{options}" unless method

          gem.version.increment!(method.to_sym)
          gem.sync!
        end

        desc 'set <GEM NAME>', "Set a gem's pre-release or metadata version"
        long_desc <<~LONGDESC, wrap: false
          Set the pre-release and metadata version of the specified gem.

          Examples:

          $ dev version set domainic-type --pre alpha.1.0.0
          $ dev version set domainic-type --meta 20240101
        LONGDESC
        at_least_one do
          option :pre, type: :string
          option :build, type: :string
        end
        def set(gem_name)
          gem = GemManager.gem(gem_name)
          raise ArgumentError, "Gem '#{gem_name}' not found" unless gem

          gem.version.pre = options[:pre] if options[:pre]
          gem.version.build = options[:build] if options[:build]
          gem.sync!
        end

        desc 'sync', 'Synchronize all gem versions'
        long_desc <<~LONGDESC, wrap: false
          Synchronize all gem versions with the latest version.
        LONGDESC
        def sync
          GemManager.gems.each(&:sync!)
        end
      end
    end
  end
end
