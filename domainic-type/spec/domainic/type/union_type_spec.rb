# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/union_type'

RSpec.describe Domainic::Type::UnionType do
  describe '#validate' do
    subject(:validate) { type.validate(value) }

    context 'when given a type that is included in the union' do
      let(:type) { described_class.new(String, Integer) }
      let(:value) { ['foo', 1].sample }

      it { is_expected.to be true }
    end

    context 'when given a type that is not included in the union' do
      let(:type) { described_class.new(String, Integer) }
      let(:value) { [nil, 1.0, :foo].sample }

      it { is_expected.to be false }
    end
  end
end
