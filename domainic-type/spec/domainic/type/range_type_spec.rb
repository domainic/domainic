# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/core/range_type'

RSpec.describe Domainic::Type::RangeType do
  subject(:type) { described_class.new }

  describe '.validate' do
    context 'when validating a valid range' do
      subject(:validation) { described_class.validate(1..10) }

      it { is_expected.to be true }
    end

    context 'when validating an invalid range' do
      subject(:validation) { described_class.validate('not a range') }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    context 'when validating a valid range' do
      subject(:validation) { described_class.validate!(1..10) }

      it { is_expected.to be true }
    end

    context 'when validating an invalid range' do
      it {
        expect do
          described_class.validate!('not a range')
        end.to raise_error(TypeError, /Expected Range, but got String/)
      }
    end
  end

  describe '#being_empty' do
    context 'when the range is empty' do
      subject(:validation) { type.being_empty.validate(1...1) }

      it { is_expected.to be true }
    end

    context 'when the range is not empty' do
      subject(:validation) { type.being_empty.validate(1..10) }

      it { is_expected.to be false }
    end
  end

  describe '#having_minimum_count' do
    context 'when the range size meets the minimum count' do
      subject(:validation) { type.having_minimum_count(5).validate(1..5) }

      it { is_expected.to be true }
    end

    context 'when the range size is below the minimum count' do
      subject(:validation) { type.having_minimum_count(5).validate(1..3) }

      it { is_expected.to be false }
    end
  end

  describe '#having_maximum_count' do
    context 'when the range size is within the maximum count' do
      subject(:validation) { type.having_maximum_count(10).validate(1..10) }

      it { is_expected.to be true }
    end

    context 'when the range size exceeds the maximum count' do
      subject(:validation) { type.having_maximum_count(10).validate(1..20) }

      it { is_expected.to be false }
    end
  end

  describe '#containing' do
    context 'when the range includes all specified elements' do
      subject(:validation) { type.containing(3, 5).validate(1..10) }

      it { is_expected.to be true }
    end

    context 'when the range does not include all specified elements' do
      subject(:validation) { type.containing(11).validate(1..10) }

      it { is_expected.to be false }
    end
  end
end
