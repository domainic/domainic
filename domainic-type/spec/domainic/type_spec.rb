# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constants'

RSpec.describe Domainic::Type do
  describe '::UNSPECIFIED' do
    subject(:unspecified) { described_class::UNSPECIFIED }

    it { is_expected.to be_an_instance_of(Object).and(be_frozen) }
  end
end
