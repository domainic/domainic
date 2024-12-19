# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/specification/enum_type'

RSpec.describe Domainic::Type::EnumType do
  describe '#validate' do
    subject(:validate) { type.validate(value) }

    context 'when given a value that matches an included literal' do
      let(:type) { described_class.new('foo', 'bar') }
      let(:value) { %w[foo bar].sample }

      it { is_expected.to be true }
    end

    context 'when given a value that does not match an included literal' do
      let(:type) { described_class.new('foo', 'bar') }
      let(:value) { 'baz' }

      it { is_expected.to be false }
    end
  end
end
