# frozen_string_literal: true

module Domainic
  module Dev
    class Gem
      # A class responsible for managing the set of paths used in the Domainic gem.
      #
      # This class provides a centralized way to access important directories and files within the {Gem}'s structure,
      # including the `gemspec`, `library`, `root`, `signature`, and `test` directories.
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class PathSet
        # @rbs @gemspec: Pathname
        # @rbs @library: Pathname
        # @rbs @root: Pathname
        # @rbs @signature: Pathname
        # @rbs @test: Pathname

        # @return [Pathname] the path to the {Gem}'s gemspec file
        attr_reader :gemspec #: Pathname

        # @return [Pathname] the path to the {Gem}'s library directory
        attr_reader :library #: Pathname

        # @return [Pathname] the path to the {Gem}'s root directory
        attr_reader :root #: Pathname

        # @return [Pathname] the path to the {Gem}'s signature directory
        attr_reader :signature #: Pathname

        # @return [Pathname] the path to the {Gem}'s test directory
        attr_reader :test #: Pathname

        # Initialize a new PathSet instance.
        #
        # @param root_directory [Pathname] the root directory of the {Gem}
        # @return [PathSet] a new instance of PathSet
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
