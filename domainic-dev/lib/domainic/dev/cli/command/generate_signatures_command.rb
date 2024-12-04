# frozen_string_literal: true

require 'domainic/dev'
require 'domainic/dev/cli/command/base_command'
require 'domainic/dev/cli/command/mixin/gem_names_argument'
require 'thor'

module Domainic
  module Dev
    class CLI < Thor
      module Command
        # A command to generate RBS type signatures for Domainic gems.
        #
        # This class extends {BaseCommand} and includes {Mixin::GemNamesArgument} to provide functionality for
        # generating, cleaning, and managing RBS type signatures for gems. It handles the full signature generation
        # workflow including cleaning directories, generating signatures, and updating RBS collections.
        #
        # @author {https://aaronmallen.me Aaron Allen}
        # @since 0.1.0
        class GenerateSignaturesCommand < BaseCommand
          include Mixin::GemNamesArgument

          # List of gems that should not have signatures generated.
          #
          # @return [Array<String>] the list of gem names to skip
          DISALLOW_SIGNATURES = %w[domainic].freeze #: Array[String]

          long_desc <<~DESC
            Generates RBS signatures for one or more Domainic gems. If no gem names are provided all RBS signatures are generated.

            Example:

            $ dev generate signatures                                           # Generate signatures for all Domainic gems
            $ dev generate signatures domainic-dev                              # Generate signatures for domainic-dev
            $ dev generate signatures domainic-dev domainic-attributer          # Generate signatures for domainic-dev and domainic-attributer
          DESC

          # Execute the signature generation command.
          #
          # @return [void]
          # @rbs () -> void
          def execute
            gems.each do |gem|
              next if DISALLOW_SIGNATURES.include?(gem.name)

              clean_sig_directory_for_gem(gem)
              generate_signatures_for_gem(gem)
              clean_signatures_for_gem(gem)
              system 'bundle', 'exec', 'rbs', 'collection', 'update'
            end
          end

          private

          # Clean RBS comments from a content string.
          #
          # @param content [String] the content to clean
          # @return [String] the cleaned content
          # @rbs (String content) -> String
          def clean_rbs_comments(content)
            lines = content.lines
            cleaned_lines = []
            comment_block_to_remove = nil

            lines.each do |line|
              comment_block_to_remove = update_comment_block(line, comment_block_to_remove)
              cleaned_lines << line unless skip_line?(line, comment_block_to_remove)
            end

            # Clean up any multiple blank lines
            content = cleaned_lines.join
            content.gsub!(/\n{3,}/, "\n\n")
            "#{content.strip}\n"
          end

          # Clean and prepare the signature directory for a gem.
          #
          # @param gem [Gem] the gem to clean signatures for
          # @return [void]
          # @rbs (Gem gem) -> void
          def clean_sig_directory_for_gem(gem)
            manifest_file = gem.paths.signature.join('manifest.yaml')
            manifest = manifest_file.read if manifest_file.exist?
            FileUtils.rm_rf(gem.paths.signature.to_s)
            FileUtils.mkdir_p(gem.paths.signature.to_s)
            manifest_file.write(manifest) unless manifest.nil?
          end

          # Clean generated signatures for a gem.
          #
          # @param gem [Gem] the gem to clean signatures for
          # @return [void]
          # @rbs (Gem gem) -> void
          def clean_signatures_for_gem(gem)
            gem.paths.signature.glob('**/*.rbs').each do |signature_file|
              content = signature_file.read
              cleaned_content = clean_rbs_comments(content)
              signature_file.write(cleaned_content)
            end
          end

          # Generate RBS signatures for a gem.
          #
          # @param gem [Gem] the gem to generate signatures for
          # @return [void]
          # @rbs (Gem gem) -> void
          def generate_signatures_for_gem(gem)
            relative_lib = gem.paths.library.relative_path_from(Domainic::Dev.root)
            relative_sig = gem.paths.signature.relative_path_from(Domainic::Dev.root)
            system 'bundle', 'exec', 'rbs-inline', relative_lib.to_s, '--opt-out', '--base', relative_lib.to_s,
                   "--output=./#{relative_sig}/"
          end

          # Check if a line starts an RBS comment block.
          #
          # @param line [String] the line to check
          # @return [Boolean] true if the line starts an RBS comment block
          # @rbs (String line) -> bool
          def rbs_comment_start?(line)
            line.strip.match?(/^\#.*@rbs/)
          end

          # Check if a line should be skipped during cleaning.
          #
          # @param line [String] the line to check
          # @param comment_block_to_remove [String, nil] the current comment block pattern
          # @return [Boolean] true if the line should be skipped
          # @rbs (String line, String? comment_block_to_remove) -> bool
          def skip_line?(line, comment_block_to_remove)
            return true if line.strip.start_with?('# Generated from')
            return true if comment_block_to_remove && line.start_with?(comment_block_to_remove)

            false
          end

          # Update the current comment block based on a line.
          #
          # @param line [String] the line to check
          # @param comment_block_to_remove [String, nil] the current comment block pattern
          # @return [String, nil] the updated comment block pattern
          # @rbs (String line, String? comment_block_to_remove) -> String?
          def update_comment_block(line, comment_block_to_remove)
            if rbs_comment_start?(line)
              (line.match(/^(\s*#)/) || [])[1]
            elsif comment_block_to_remove && !line.start_with?(comment_block_to_remove)
              nil
            else
              comment_block_to_remove
            end
          end
        end
      end
    end
  end
end
