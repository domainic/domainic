# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/predicate_constraint'

RSpec.describe Domainic::Type::Constraint::PredicateConstraint do
  describe '.expecting' do
    subject(:expecting) { described_class.new(:self).expecting(expectation) }

    context 'when given a Proc' do
      let(:expectation) { lambda(&:positive?) }

      it 'is expected not to raise an error' do
        expect { expecting }.not_to raise_error
      end
    end

    context 'when given something other than a Proc', rbs: :skip do
      let(:expectation) { 'not a proc' }

      it 'is expected to raise an ArgumentError' do
        expect { expecting }
          .to raise_error(ArgumentError, 'Expectation must be a Proc')
      end
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self).expecting(predicate) }

    context 'with a simple numeric predicate' do
      let(:predicate) { lambda(&:positive?) }

      context 'when the predicate returns true' do
        let(:actual_value) { 1 }

        it { is_expected.to be true }
      end

      context 'when the predicate returns false' do
        let(:actual_value) { -1 }

        it { is_expected.to be false }
      end
    end

    context 'with a complex object predicate' do
      let(:point_class) { Struct.new(:x, :y) }
      let(:predicate) { ->(point) { point.x == point.y } }

      context 'when the predicate returns true' do
        let(:actual_value) { point_class.new(1, 1) }

        it { is_expected.to be true }
      end

      context 'when the predicate returns false' do
        let(:actual_value) { point_class.new(1, 2) }

        it { is_expected.to be false }
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self) }

    it { is_expected.to eq('') }
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    let(:constraint) do
      described_class.new(:self).with_options(**options)
    end

    context 'when a violation description is provided' do
      let(:options) { { violation_description: 'not greater than zero' } }

      it { is_expected.to eq('not greater than zero') }
    end

    context 'when no violation description is provided' do
      let(:options) { {} }

      it { is_expected.to be_empty }
    end
  end
end
