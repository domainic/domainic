# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Dev do
  describe '.root' do
    subject(:root) { described_class.root }

    it 'is expected to be equal to the root path of the Domainic monorepo' do
      expect(root).to eq(Pathname.new(File.expand_path('../../../', File.dirname(__FILE__))))
    end
  end
end
