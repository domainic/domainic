# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Dev do
  describe '.root' do
    subject(:root) { described_class.root }

    it { is_expected.to be_an_instance_of(Pathname) }
  end
end
