# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/emptiness_constraint'
require 'set'

RSpec.describe Domainic::Type::Constraint::EmptinessConstraint do
  describe '.new' do
    subject(:constraint) { described_class.new(:self) }

    it { expect { constraint }.not_to raise_error }
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self) }

    context 'with arrays' do
      context 'when empty' do
        let(:actual_value) { [] }

        it { is_expected.to be true }
      end

      context 'when not empty' do
        let(:actual_value) { [1, 2, 3] }

        it { is_expected.to be false }
      end
    end

    context 'with sets' do
      context 'when empty' do
        let(:actual_value) { Set.new }

        it { is_expected.to be true }
      end

      context 'when not empty' do
        let(:actual_value) { Set[1, 2, 3] }

        it { is_expected.to be false }
      end
    end

    context 'with strings' do
      context 'when empty' do
        let(:actual_value) { [] }

        it { is_expected.to be true }
      end

      context 'when not empty' do
        let(:actual_value) { %w[a b c] }

        it { is_expected.to be false }
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self) }

    it { is_expected.to eq('empty') }
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    let(:constraint) { described_class.new(:self) }

    it { is_expected.to eq('not empty') }
  end
end
