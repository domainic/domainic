# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/equality_constraint'

RSpec.describe Domainic::Type::Constraint::EqualityConstraint do
  describe '.new' do
    subject(:constraint) { described_class.new(:self, expected_value) }

    let(:expected_value) { 42 }

    it { expect { constraint }.not_to raise_error }
  end

  describe '#description' do
    subject(:description) { constraint.description }

    let(:constraint) { described_class.new(:self, expected_value) }
    let(:expected_value) { 42 }

    it { is_expected.to eq('equal to 42') }
  end

  describe '#expecting' do
    subject(:expecting) { constraint.expecting(new_value) }

    let(:constraint) { described_class.new(:self, 42) }
    let(:new_value) { 100 }

    it 'is expected to update the expected value' do
      expecting
      expect(constraint.satisfied?(100)).to be true
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self, expected_value) }

    context 'with numbers' do
      let(:expected_value) { 42 }

      context 'when equal' do
        let(:actual_value) { 42 }

        it { is_expected.to be true }
      end

      context 'when not equal' do
        let(:actual_value) { 41 }

        it { is_expected.to be false }
      end
    end

    context 'with strings' do
      let(:expected_value) { 'test' }

      context 'when equal' do
        let(:actual_value) { 'test' }

        it { is_expected.to be true }
      end

      context 'when not equal' do
        let(:actual_value) { 'other' }

        it { is_expected.to be false }
      end
    end

    context 'with arrays' do
      let(:expected_value) { [1, 2, 3] }

      context 'when equal' do
        let(:actual_value) { [1, 2, 3] }

        it { is_expected.to be true }
      end

      context 'when not equal' do
        let(:actual_value) { [3, 2, 1] }

        it { is_expected.to be false }
      end
    end

    context 'with custom objects' do
      let(:point_class) { Struct.new(:x, :y) }
      let(:expected_value) { point_class.new(1, 2) }

      context 'when equal' do
        let(:actual_value) { point_class.new(1, 2) }

        it { is_expected.to be true }
      end

      context 'when not equal' do
        let(:actual_value) { point_class.new(2, 1) }

        it { is_expected.to be false }
      end
    end
  end

  describe '#violation_description' do
    subject(:violation_description) { constraint.violation_description }

    let(:constraint) { described_class.new(:self, expected_value) }
    let(:expected_value) { 42 }

    it { is_expected.to eq('not equal to 42') }
  end
end
