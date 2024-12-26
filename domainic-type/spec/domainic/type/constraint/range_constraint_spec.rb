# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/range_constraint'

RSpec.describe Domainic::Type::Constraint::RangeConstraint do
  shared_examples 'coerces and validates expectation' do
    context 'when given a validate expectation' do
      let(:expectation) { { minimum: 1, maximum: 10 } }

      it { expect { subject }.not_to raise_error }
    end

    context 'when given something other than a Hash', rbs: :skip do
      let(:expectation) { 'not a Hash' }

      it { expect { subject }.to raise_error(ArgumentError, %r{must be a Hash including :minimum and/or :maximum}) }
    end

    context 'when given a Hash without :minimum or :maximum', rbs: :skip do
      let(:expectation) { { not_minimum: 1, not_maximum: 10 } }

      it { expect { subject }.to raise_error(ArgumentError, %r{must be a Hash including :minimum and/or :maximum}) }
    end

    context 'when given a Hash with invalid values', rbs: :skip do
      let(:expectation) { { minimum: 'not a number', maximum: 'not a number' } }

      it { expect { subject }.to raise_error(ArgumentError, /must be a Numeric/) }
    end

    context 'when given a Hash with a minimum greater than the maximum', rbs: :skip do
      let(:expectation) { { minimum: 10, maximum: 1 } }

      it { expect { subject }.to raise_error(ArgumentError, ':minimum must be less than or equal to :maximum') }
    end

    context 'when given a Hash and a previous expectation exists' do
      it 'is expected not to raise an error' do
        constraint = described_class.new(:self).expecting({ minimum: 1 })
        expect { constraint.expecting({ maximum: 2 }) }.not_to raise_error
      end

      it 'is expected to merge the expectation with the existing expectation' do
        constraint = described_class.new(:self).expecting({ minimum: 1 })
        constraint.expecting({ maximum: 2 })
        expect(constraint).to(be_satisfied(1).and(be_satisfied(2)))
      end
    end
  end

  describe '#expecting' do
    subject(:expecting) { constraint.expecting(expectation) }

    let(:constraint) { described_class.new(:self) }

    include_examples 'coerces and validates expectation'
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:actual_value) { 1 }

    context 'when the value is within the range' do
      let(:constraint) { described_class.new(:self).expecting({ minimum: 1, maximum: 2 }) }

      it { is_expected.to be true }
    end

    context 'when the value is less than the minimum' do
      let(:constraint) { described_class.new(:self).expecting({ minimum: 2 }) }

      it { is_expected.to be false }
    end

    context 'when the value is greater than the maximum' do
      let(:constraint) { described_class.new(:self).expecting({ maximum: 0 }) }

      it { is_expected.to be false }
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(expectation).with_options(options) }
    let(:options) { {} }

    context 'when given a minimum and a maximum' do
      let(:expectation) { { minimum: 1, maximum: 10 } }

      it { is_expected.to eq('greater than or equal to 1 and less than or equal to 10') }

      context 'with inclusive false' do
        let(:expectation) { { minimum: 1, maximum: 10 } }
        let(:options) { { inclusive: false } }

        it { is_expected.to eq('greater than 1 and less than 10') }
      end
    end

    context 'when given only a minimum' do
      let(:expectation) { { minimum: 0 } }

      it { is_expected.to eq('greater than or equal to 0') }

      context 'with inclusive false' do
        let(:expectation) { { minimum: 0 } }
        let(:options) { { inclusive: false } }

        it { is_expected.to eq('greater than 0') }
      end
    end

    context 'when given only a maximum' do
      let(:expectation) { { maximum: 100 } }

      it { is_expected.to eq('less than or equal to 100') }

      context 'with inclusive false' do
        let(:expectation) { { maximum: 100 } }
        let(:options) { { inclusive: false } }

        it { is_expected.to eq('less than 100') }
      end
    end
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    before { constraint.satisfied?(11) }

    let(:constraint) { described_class.new(:self).expecting({ minimum: 1, maximum: 10 }) }

    it { is_expected.to eq('11') }
  end
end
