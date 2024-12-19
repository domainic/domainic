# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/specification/anything_type'

RSpec.describe Domainic::Type::AnythingType do
  describe '#validate' do
    subject(:validate) { type.validate(value) }

    let(:type) { described_class.new }
    let(:value) { 'anything' }

    it { is_expected.to be true }

    context 'when excluding a type' do
      before { type.but(String) }

      context 'with an invalid value' do
        it { is_expected.to be false }
      end
    end
  end
end
