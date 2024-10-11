# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/AnyInstance
RSpec.describe Domainic::Dev::CLI::Lint do
  before do
    allow(Thor).to receive(:puts) # suppress warnings
  end

  describe '#all' do
    subject(:all) { described_class.new.all }

    it 'is expected to run all the linters' do
      %i[markdown ruby].each do |linter|
        expect_any_instance_of(described_class).to receive(:invoke).with(linter)
      end

      all
    end
  end

  describe '#markdown' do
    subject(:markdown) { described_class.new.invoke(:markdown) }

    it 'is expected to run the markdown linter' do
      expect_any_instance_of(described_class).to receive(:system).with('bundle exec mdl **/*.md', exception: true)
      markdown
    end
  end

  describe '#ruby' do
    subject(:ruby) { described_class.new.invoke(:ruby) }

    it 'is expected to run the ruby linter' do
      expect_any_instance_of(described_class).to receive(:system).with('bundle', 'exec', 'rubocop', exception: true)
      ruby
    end
  end
end
# rubocop:enable RSpec/AnyInstance
