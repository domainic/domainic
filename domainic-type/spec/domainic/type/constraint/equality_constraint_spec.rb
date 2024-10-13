# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/equality_constraint'

RSpec.describe Domainic::Type::Constraint::EqualityConstraint do
  let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

  describe '#validate' do
    subject(:validate) { constraint.validate(subject_value) }

    context 'when subject and expected are equal' do
      let(:subject_value) { 'test' }

      context 'when expected is a single value' do
        before { constraint.expected = 'test' }

        it { is_expected.to be true }
      end

      context 'when expected is an array of values' do
        before { constraint.expected = %w[test test] }

        context 'with default expectation qualifier (:all?)' do
          it { is_expected.to be true }
        end

        context 'when using :all? qualifier' do
          before { constraint.expectation_qualifier = :all? }

          it { is_expected.to be true }
        end

        context 'when using :any? qualifier' do
          before { constraint.expectation_qualifier = :any? }

          it { is_expected.to be true }
        end

        context 'when using :none? qualifier' do
          before { constraint.expectation_qualifier = :none? }

          it { is_expected.to be false }
        end

        context 'when using :one? qualifier' do
          before { constraint.expectation_qualifier = :one? }

          it { is_expected.to be false } # Because subject matches more than one expected value
        end
      end
    end

    context 'when subject and expected are not equal' do
      let(:subject_value) { 'test' }

      context 'when expected is a single value' do
        before { constraint.expected = 'example' }

        it { is_expected.to be false }
      end

      context 'when expected is an array of values' do
        before { constraint.expected = %w[example sample] }

        context 'with default expectation qualifier (:all?)' do
          it { is_expected.to be false }
        end

        context 'when using :all? qualifier' do
          before { constraint.expectation_qualifier = :all? }

          it { is_expected.to be false }
        end

        context 'when using :any? qualifier' do
          before { constraint.expectation_qualifier = :any? }

          it { is_expected.to be false }
        end

        context 'when using :none? qualifier' do
          before { constraint.expectation_qualifier = :none? }

          it { is_expected.to be true }
        end

        context 'when using :one? qualifier' do
          before { constraint.expectation_qualifier = :one? }

          it { is_expected.to be false }
        end
      end
    end

    context 'when subject matches only some of the expected values' do
      let(:subject_value) { 'test' }

      before { constraint.expected = %w[test example] }

      context 'with default expectation qualifier (:all?)' do
        it { is_expected.to be false } # Subject does not match all expected values
      end

      context 'when using :all? qualifier' do
        before { constraint.expectation_qualifier = :all? }

        it { is_expected.to be false }
      end

      context 'when using :any? qualifier' do
        before { constraint.expectation_qualifier = :any? }

        it { is_expected.to be true } # Subject matches at least one expected value
      end

      context 'when using :none? qualifier' do
        before { constraint.expectation_qualifier = :none? }

        it { is_expected.to be false }
      end

      context 'when using :one? qualifier' do
        before { constraint.expectation_qualifier = :one? }

        it { is_expected.to be true } # Subject matches exactly one expected value
      end
    end

    context 'when subject and expected are of different types' do
      let(:subject_value) { '10' }

      before { constraint.expected = 10 }

      it { is_expected.to be false }
    end

    context 'with multiple expected values and qualifiers' do
      before { constraint.expected = expected_values }

      let(:subject_value) { subject_input }

      context 'when using :all? qualifier' do
        before { constraint.expectation_qualifier = :all? }

        context 'when subject matches all expected values' do
          let(:expected_values) { %w[test test] }
          let(:subject_input) { 'test' }

          it { is_expected.to be true }
        end

        context 'when subject does not match all expected values' do
          let(:expected_values) { %w[test example] }
          let(:subject_input) { 'test' }

          it { is_expected.to be false }
        end
      end

      context 'when using :any? qualifier' do
        before { constraint.expectation_qualifier = :any? }

        context 'when subject matches any expected value' do
          let(:expected_values) { %w[example test] }
          let(:subject_input) { 'test' }

          it { is_expected.to be true }
        end

        context 'when subject does not match any expected value' do
          let(:expected_values) { %w[example sample] }
          let(:subject_input) { 'test' }

          it { is_expected.to be false }
        end
      end

      context 'when using :none? qualifier' do
        before { constraint.expectation_qualifier = :none? }

        context 'when subject does not match any expected value' do
          let(:expected_values) { %w[example sample] }
          let(:subject_input) { 'test' }

          it { is_expected.to be true }
        end

        context 'when subject matches any expected value' do
          let(:expected_values) { %w[test sample] }
          let(:subject_input) { 'test' }

          it { is_expected.to be false }
        end
      end

      context 'when using :one? qualifier' do
        before { constraint.expectation_qualifier = :one? }

        context 'when subject matches exactly one expected value' do
          let(:expected_values) { %w[test example] }
          let(:subject_input) { 'test' }

          it { is_expected.to be true }
        end

        context 'when subject matches more than one expected value' do
          let(:expected_values) { %w[test test] }
          let(:subject_input) { 'test' }

          it { is_expected.to be false } # Subject matches more than one expected value
        end

        context 'when subject does not match any expected value' do
          let(:expected_values) { %w[example sample] }
          let(:subject_input) { 'test' }

          it { is_expected.to be false }
        end
      end
    end

    context 'when negated' do
      before do
        constraint.negated = true
        constraint.expected = expected_value
      end

      let(:subject_value) { subject_input }

      context 'when subject equals expected value' do
        let(:expected_value) { 'test' }
        let(:subject_input) { 'test' }

        it { is_expected.to be false }
      end

      context 'when subject does not equal expected value' do
        let(:expected_value) { 'example' }
        let(:subject_input) { 'test' }

        it { is_expected.to be true }
      end
    end
  end
end
