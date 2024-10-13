# frozen_string_literal: true

# spec/domainic/type/constraint/divisibility_constraint_spec.rb

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/divisibility_constraint'

RSpec.describe Domainic::Type::Constraint::DivisibilityConstraint do
  let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

  describe '#validate' do
    subject(:validate) { constraint.validate(subject_value) }

    context 'when subject and expected are numeric' do
      context 'with integer values' do
        let(:subject_value) { 10 }

        context 'when subject is divisible by expected value' do
          before { constraint.expected = 2 }

          it { is_expected.to be true }
        end

        context 'when subject is not divisible by expected value' do
          before { constraint.expected = 3 }

          it { is_expected.to be false }
        end
      end

      context 'with floating-point values' do
        let(:subject_value) { 10.0 }

        context 'when subject is divisible by expected value within tolerance' do
          before { constraint.expected = 0.1 }

          it { is_expected.to be true }
        end

        context 'when subject is not divisible by expected value' do
          before { constraint.expected = 0.3 }

          it { is_expected.to be false }
        end
      end

      context 'when subject is zero' do
        let(:subject_value) { 0 }

        context 'with non-zero expected value' do
          before { constraint.expected = 5 }

          it { is_expected.to be true }
        end

        context 'with zero expected value' do
          before { constraint.expected = 0 }

          it { is_expected.to be false }
        end
      end

      context 'when expected value is zero (to avoid division by zero)' do
        let(:subject_value) { 10 }

        before { constraint.expected = 0 }

        it { is_expected.to be false }
      end

      context 'with negative numbers' do
        context 'when both subject and expected value are negative and divisible' do
          let(:subject_value) { -10 }

          before { constraint.expected = -2 }

          it { is_expected.to be true }
        end

        context 'when subject is negative and expected value is positive and divisible' do
          let(:subject_value) { -10 }

          before { constraint.expected = 2 }

          it { is_expected.to be true }
        end

        context 'when subject is positive and expected value is negative and divisible' do
          let(:subject_value) { 10 }

          before { constraint.expected = -2 }

          it { is_expected.to be true }
        end

        context 'when subject and expected value are not divisible' do
          let(:subject_value) { -10 }

          before { constraint.expected = -3 }

          it { is_expected.to be false }
        end
      end
    end

    context 'when subject or expected is non-numeric' do
      context 'when subject is non-numeric' do
        let(:subject_value) { 'abc' }

        before { constraint.expected = 2 }

        it { is_expected.to be false }
      end

      context 'when expected value is non-numeric' do
        let(:subject_value) { 10 }

        before { constraint.expected = 'xyz' }

        it { is_expected.to be false }
      end

      context 'when both subject and expected value are non-numeric' do
        let(:subject_value) { 'abc' }

        before { constraint.expected = 'xyz' }

        it { is_expected.to be false }
      end
    end

    context 'with multiple expected values and qualifiers' do
      before { constraint.expected = expected_values }

      context 'when using :all? qualifier' do
        before { constraint.expectation_qualifier = :all? }

        let(:subject_value) { 10 }

        context 'when subject is divisible by all expected values' do
          let(:expected_values) { [2, 5] }

          it { is_expected.to be true }
        end

        context 'when subject is not divisible by all expected values' do
          let(:expected_values) { [2, 3] }

          it { is_expected.to be false }
        end
      end

      context 'when using :any? qualifier' do
        before { constraint.expectation_qualifier = :any? }

        let(:subject_value) { 10 }

        context 'when subject is divisible by any expected value' do
          let(:expected_values) { [3, 5] }

          it { is_expected.to be true }
        end

        context 'when subject is not divisible by any expected value' do
          let(:expected_values) { [3, 7] }

          it { is_expected.to be false }
        end
      end

      context 'when using :none? qualifier' do
        before { constraint.expectation_qualifier = :none? }

        let(:subject_value) { 10 }

        context 'when subject is not divisible by any expected value' do
          let(:expected_values) { [3, 7] }

          it { is_expected.to be true }
        end

        context 'when subject is divisible by any expected value' do
          let(:expected_values) { [2, 3] }

          it { is_expected.to be false }
        end
      end

      context 'when using :one? qualifier' do
        before { constraint.expectation_qualifier = :one? }

        let(:subject_value) { 10 }

        context 'when subject is divisible by exactly one expected value' do
          let(:expected_values) { [3, 7, 5] }

          it { is_expected.to be true }
        end

        context 'when subject is divisible by more than one expected value' do
          let(:expected_values) { [2, 5] }

          it { is_expected.to be false }
        end

        context 'when subject is not divisible by any expected value' do
          let(:expected_values) { [3, 7] }

          it { is_expected.to be false }
        end
      end
    end

    context 'when negated' do
      before do
        constraint.negated = true
        constraint.expected = expected_value
      end

      let(:subject_value) { 10 }

      context 'when subject is divisible by expected value' do
        let(:expected_value) { 2 }

        it { is_expected.to be false }
      end

      context 'when subject is not divisible by expected value' do
        let(:expected_value) { 3 }

        it { is_expected.to be true }
      end
    end
  end
end
