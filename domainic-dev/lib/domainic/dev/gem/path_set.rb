# frozen_string_literal: true

module Domainic
  module Dev
    class Gem
      # Important {Gem} paths.
      #
      # @since 0.1.0
      class PathSet
        # @rbs @gemspec: Pathname
        # @rbs @library: Pathname
        # @rbs @root: Pathname
        # @rbs @signature: Pathname
        # @rbs @test: Pathname

        # @!attribute [r] gemspec
        #   The {Gem}'s gemspec file path.
        #
        #   @return [Pathname] the {Gem}'s gemspec file path.
        attr_reader :gemspec #: Pathname

        # @!attribute [r] library
        #   The {Gem}'s library directory path.
        #
        #   @return [Pathname] the {Gem}'s library directory path.
        attr_reader :library #: Pathname

        # @!attribute [r] root
        #   The {Gem}'s root directory path.
        #
        #   @return [Pathname] the {Gem}'s root directory path.
        attr_reader :root #: Pathname

        # @!attribute [r] signature
        #   The {Gem}'s signature directory path.
        #
        #   @return [Pathname] the {Gem}'s signature directory path.
        attr_reader :signature #: Pathname

        # @!attribute [r] test
        #   The {Gem}'s test directory path.
        #
        #   @return [Pathname] the {Gem}'s test directory path.
        attr_reader :test #: Pathname

        # Initialize the a new instance of PathSet.
        #
        # @param root_directory [Pathname] the root directory of the {Gem}.
        # @return [PathSet] the new instance of PathSet.
        # @rbs (Pathname root_directory) -> void
        def initialize(root_directory)
          @gemspec = root_directory.glob('*.gemspec').first
          @library = root_directory.join('lib')
          @root = root_directory
          @signature = root_directory.join('sig')
          @test = root_directory.join('spec')
        end
      end
    end
  end
end
