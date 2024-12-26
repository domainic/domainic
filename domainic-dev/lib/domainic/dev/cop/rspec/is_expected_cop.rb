# frozen_string_literal: true

require 'rubocop'

module Domainic
  module Dev
    module Cop
      # steep:ignore:start
      module RSpec
        # This cop ensures that `it` blocks in RSpec examples begin with "is expected"
        # in their descriptions. This allows for phrases like:
        #
        #   it "is expected to be true" do
        #     expect(subject).to be true
        #   end
        #
        #   it "is expected not to raise an error" do
        #     expect { some_call }.not_to raise_error
        #   end
        #
        # The cop flags non-conforming descriptions:
        #
        #   it "should be true" do
        #     expect(subject).to be true
        #   end
        #
        # In the future, configuration options could be added to refine the style
        # or allowable phrases.
        class IsExpectedCop < RuboCop::Cop::Base
          MSG = 'Use "is expected" style in RSpec `it` blocks.'
          RESTRICT_ON_SEND = [:it].freeze

          # Match `it "..." do ... end` or `it(...) { ... }`
          def_node_matcher :it_with_description?, <<~PATTERN
            (send nil? :it (str $_) ...)
          PATTERN

          def on_send(node)
            description = it_with_description?(node)
            return unless description

            # Skip examples that already start with "is expected"
            return if description.start_with?('is expected')

            add_offense(node.loc.selector, message: MSG)
          end
        end
      end
      # steep:ignore:end
    end
  end
end
