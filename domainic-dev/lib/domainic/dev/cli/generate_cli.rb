# frozen_string_literal: true

require 'domainic/dev/cli/command/generate_signatures_command'
require 'domainic/dev/generator/gem_generator'
require 'domainic/dev/generator/milestone_doc_generator'
require 'domainic/dev/generator/project_doc_generator'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      # A command line interface for generation tools in the Domainic::Dev project.
      #
      # This class extends Thor to provide a unified interface for various generation tools. Currently supports
      # RBS signature generation via {Command::GenerateSignaturesCommand}.
      #
      # @author {https://aaronmallen.me Aaron Allen}
      # @since 0.1.0
      class GenerateCLI < Thor
        # steep:ignore:start
        map 'sig' => 'signatures'

        long_desc Command::GenerateSignaturesCommand.long_desc, wrap: false
        register(
          Command::GenerateSignaturesCommand,
          'signatures',
          'signatures [GEM_NAMES]',
          'Generate RBS signatures for Domainic gems'
        )

        register(
          Generator::GemGenerator,
          'gem',
          'gem NAME',
          'Generate a new Domainic gem'
        )

        register(
          Generator::MilestoneDocGenerator,
          'milestone_doc',
          'milestone_doc <NAME> <ID>',
          'Generate milestone documentation'
        )

        register(
          Generator::ProjectDocGenerator,
          'project_doc',
          'project_doc <NAME> <ID>',
          'Generate project documentation'
        )
        # steep:ignore:end
      end
    end
  end
end
