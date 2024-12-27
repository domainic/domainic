# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/core_extended/set_type'

RSpec.describe Domainic::Type::SetType do
  subject(:type) { described_class.new }

  describe '.validate' do
    context 'when validating a valid set' do
      subject(:validation) { type.validate(Set.new([1, 2, 3])) }

      it { is_expected.to be true }
    end

    context 'when validating an invalid type' do
      subject(:validation) { type.validate([1, 2, 3]) }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    context 'when validating a valid set' do
      subject(:validation) { type.validate!(Set.new([1, 2, 3])) }

      it { is_expected.to be true }
    end

    context 'when validating an invalid type' do
      it { expect { type.validate!([1, 2, 3]) }.to raise_error(TypeError, /Expected Set, but got Array/) }
    end
  end

  describe '#being_empty' do
    context 'when the set is empty' do
      subject(:validation) { type.being_empty.validate(Set.new) }

      it { is_expected.to be true }
    end

    context 'when the set is not empty' do
      subject(:validation) { type.being_empty.validate(Set.new([1])) }

      it { is_expected.to be false }
    end
  end

  describe '#having_minimum_count' do
    context 'when the set size meets the minimum count' do
      subject(:validation) { type.having_minimum_count(2).validate(Set.new([1, 2])) }

      it { is_expected.to be true }
    end

    context 'when the set size is below the minimum count' do
      subject(:validation) { type.having_minimum_count(2).validate(Set.new([1])) }

      it { is_expected.to be false }
    end
  end

  describe '#having_maximum_count' do
    context 'when the set size is within the maximum count' do
      subject(:validation) { type.having_maximum_count(3).validate(Set.new([1, 2])) }

      it { is_expected.to be true }
    end

    context 'when the set size exceeds the maximum count' do
      subject(:validation) { type.having_maximum_count(3).validate(Set.new([1, 2, 3, 4])) }

      it { is_expected.to be false }
    end
  end

  describe '#containing' do
    context 'when the set includes all specified elements' do
      subject(:validation) { type.containing(1, 2).validate(Set.new([1, 2, 3])) }

      it { is_expected.to be true }
    end

    context 'when the set does not include all specified elements' do
      subject(:validation) { type.containing(4).validate(Set.new([1, 2, 3])) }

      it { is_expected.to be false }
    end
  end
end
