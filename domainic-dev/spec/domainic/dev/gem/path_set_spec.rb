# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Dev::Gem::PathSet do
  describe '.new' do
    subject(:path_set) { described_class.new(root_directory) }

    before do
      allow(root_directory).to receive(:glob).with('*.gemspec').and_return([mock_gemspec_path])
    end

    let(:mock_gemspec_path) { Pathname.new('fake/root/test.gemspec') }
    let(:root_directory) { Pathname.new('fake/root') }

    it {
      expect(path_set).to have_attributes(
        gemspec: mock_gemspec_path,
        library: root_directory.join('lib'),
        root: root_directory,
        signature: root_directory.join('sig'),
        test: root_directory.join('spec')
      )
    }
  end
end
