# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/structural/ordering_constraint'

RSpec.describe Domainic::Type::Constraint::OrderingConstraint do
  describe '.new' do
    subject(:constraint) { described_class.new(:self) }

    it { expect { constraint }.not_to raise_error }
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self) }

    context 'with integers' do
      context 'when ordered' do
        let(:actual_value) { [1, 2, 3] }

        it { is_expected.to be true }
      end

      context 'when not ordered' do
        let(:actual_value) { [1, 3, 2] }

        it { is_expected.to be false }
      end

      context 'when containing duplicates in order' do
        let(:actual_value) { [1, 2, 2, 3] }

        it { is_expected.to be true }
      end
    end

    context 'with floats' do
      context 'when ordered' do
        let(:actual_value) { [1.0, 1.5, 2.0] }

        it { is_expected.to be true }
      end

      context 'when not ordered' do
        let(:actual_value) { [1.5, 1.0, 2.0] }

        it { is_expected.to be false }
      end
    end

    context 'with strings' do
      context 'when ordered' do
        let(:actual_value) { %w[a b c] }

        it { is_expected.to be true }
      end

      context 'when not ordered' do
        let(:actual_value) { %w[b a c] }

        it { is_expected.to be false }
      end
    end

    context 'with mixed comparable types' do
      context 'when ordered' do
        let(:actual_value) { [1, 1.5, 2] }

        it { is_expected.to be true }
      end

      context 'when not ordered' do
        let(:actual_value) { [2, 1, 1.5] }

        it { is_expected.to be false }
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self) }

    it { is_expected.to eq('ordered') }
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    let(:constraint) { described_class.new(:self) }

    it { is_expected.to eq('not ordered') }
  end
end
