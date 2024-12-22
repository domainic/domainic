# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/divisibility_constraint'

RSpec.describe Domainic::Type::Constraint::DivisibilityConstraint do
  describe '#expecting' do
    subject(:expecting) { constraint.expecting(new_value) }

    let(:constraint) { described_class.new(:self).expecting(5) }
    let(:new_value) { 3 }

    # Split into two separate examples to fix RuboCop offense
    it 'is expected to make values not divisible by the new divisor fail' do
      expecting
      expect(constraint.satisfied?(4)).to be false # Not divisible by 3
    end

    it 'is expected to make values divisible by the new divisor pass' do
      expecting
      expect(constraint.satisfied?(9)).to be true # Divisible by 3
    end

    context 'when the expected value is zero' do
      let(:new_value) { 0 }

      it 'is expected to raise an error' do
        expect { expecting }.to raise_error(ArgumentError, 'Expectation must be non-zero')
      end
    end

    context 'when the expected value is not numeric' do
      let(:new_value) { 'not a number' }

      it 'is expected to raise an error' do
        expect { expecting }.to raise_error(ArgumentError, 'Expectation must be Numeric')
      end
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self).expecting(expected_value) }
    let(:expected_value) { 5 }

    context 'with integer values' do
      context 'when evenly divisible' do
        let(:actual_value) { 15 }

        it { is_expected.to be true }
      end

      context 'when not evenly divisible' do
        let(:actual_value) { 17 }

        it { is_expected.to be false }
      end
    end

    context 'with floating point values' do
      let(:expected_value) { 0.1 }

      context 'when evenly divisible within default tolerance' do
        let(:actual_value) { 0.3 }

        it { is_expected.to be true }
      end

      context 'when not evenly divisible' do
        let(:actual_value) { 0.35 }

        it { is_expected.to be false }
      end
    end

    context 'with custom tolerance' do
      let(:constraint) { described_class.new(:self).expecting(expected_value).with_options(tolerance: 1e-3) }
      let(:expected_value) { 3 }

      context 'when within tolerance' do
        let(:actual_value) { 9.002 }

        it { is_expected.to be true }
      end

      context 'when outside tolerance' do
        let(:actual_value) { 9.01 }

        it { is_expected.to be false }
      end
    end

    context 'with non-numeric values', rbs: :skip do
      let(:actual_value) { 'not a number' }

      it { is_expected.to be false }
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(expected_value) }
    let(:expected_value) { 5 }

    it { is_expected.to eq('divisible by 5') }
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    let(:constraint) { described_class.new(:self).expecting(expected_value) }
    let(:expected_value) { 5 }

    context 'when value is not numeric', rbs: :skip do
      before { constraint.satisfied?('not a number') }

      it { is_expected.to eq('not Numeric') }
    end

    context 'when value is not divisible' do
      before { constraint.satisfied?(7) }

      it { is_expected.to eq('not divisible by 5') }
    end
  end
end
