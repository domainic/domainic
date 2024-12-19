# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/comparison/inclusion_constraint'

RSpec.describe Domainic::Type::Constraint::InclusionConstraint do
  describe '#expecting' do
    subject(:expecting) { constraint.expecting(new_value) }

    context 'with single values' do
      let(:constraint) { described_class.new(:self).expecting(42) }
      let(:new_value) { 100 }

      it 'is expected to add to the expected values' do
        expecting
        expect(constraint.short_description).to eq('including 42 and 100')
      end
    end

    context 'with enumerable values' do
      let(:constraint) { described_class.new(:self).expecting(42) }
      let(:new_value) { [100, 200] }

      it 'is expected to add all values' do
        expecting
        expect(constraint.short_description).to eq('including 42, 100 and 200')
      end
    end

    context 'when adding multiple times' do
      let(:constraint) { described_class.new(:self) }

      it 'is expected to accumulate values' do
        constraint.expecting(1).expecting(2).expecting(3)
        expect(constraint.short_description).to eq('including 1, 2 and 3')
      end
    end
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    context 'with single value' do
      let(:constraint) { described_class.new(:self).expecting(expected_value) }

      context 'with arrays' do
        let(:expected_value) { 2 }

        context 'when including the value' do
          let(:actual_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when not including the value' do
          let(:actual_value) { [1, 3, 4] }

          it { is_expected.to be false }
        end
      end

      context 'with ranges' do
        let(:expected_value) { 5 }

        context 'when including the value' do
          let(:actual_value) { 1..10 }

          it { is_expected.to be true }
        end

        context 'when not including the value' do
          let(:actual_value) { 11..20 }

          it { is_expected.to be false }
        end
      end

      context 'with strings' do
        let(:expected_value) { 'b' }

        context 'when including the value' do
          let(:actual_value) { 'abc' }

          it { is_expected.to be true }
        end

        context 'when not including the value' do
          let(:actual_value) { 'ac' }

          it { is_expected.to be false }
        end
      end
    end

    context 'with multiple values' do
      let(:constraint) { described_class.new(:self).expecting([1, 2]) }

      context 'when including all values' do
        let(:actual_value) { [1, 2, 3] }

        it { is_expected.to be true }
      end

      context 'when missing some values' do
        let(:actual_value) { [1, 3] }

        it { is_expected.to be false }
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    context 'with single value' do
      let(:constraint) { described_class.new(:self).expecting(42) }

      it { is_expected.to eq('including 42') }
    end

    context 'with two values' do
      let(:constraint) { described_class.new(:self).expecting([1, 2]) }

      it { is_expected.to eq('including 1 and 2') }
    end

    context 'with more than two values' do
      let(:constraint) { described_class.new(:self).expecting([1, 2, 3]) }

      it { is_expected.to eq('including 1, 2 and 3') }
    end
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) do
      constraint.satisfied?(actual_value)
      constraint.short_violation_description
    end

    context 'with single value' do
      let(:constraint) { described_class.new(:self).expecting(42) }
      let(:actual_value) { [] }

      it { is_expected.to eq('excluding 42') }
    end

    context 'with multiple values' do
      let(:constraint) { described_class.new(:self).expecting([1, 2, 3]) }

      context 'when missing one value' do
        let(:actual_value) { [1, 2] }

        it { is_expected.to eq('excluding 3') }
      end

      context 'when missing two values' do
        let(:actual_value) { [1] }

        it { is_expected.to eq('excluding 2 and 3') }
      end

      context 'when missing all values' do
        let(:actual_value) { [] }

        it { is_expected.to eq('excluding 1, 2 and 3') }
      end

      context 'with out of order matches' do
        let(:actual_value) { [3, 1] }

        it { is_expected.to eq('excluding 2') }
      end
    end
  end
end
