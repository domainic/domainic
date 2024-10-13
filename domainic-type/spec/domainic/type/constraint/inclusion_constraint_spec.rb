# frozen_string_literal: true

# spec/domainic/type/constraint/inclusion_constraint_spec.rb

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/inclusion_constraint'

RSpec.describe Domainic::Type::Constraint::InclusionConstraint do
  subject(:validate) { constraint.validate(subject_value) }

  let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

  describe '#validate' do
    context 'when subject is an array' do
      let(:subject_value) { [1, 2, 3, 4, 5] }

      context 'with default expectation qualifier (:all?)' do
        before { constraint.expected = expected_values }

        context 'when all expected values are included in the subject' do
          let(:expected_values) { [2, 3] }

          it { is_expected.to be true }
        end

        context 'when not all expected values are included in the subject' do
          let(:expected_values) { [2, 6] }

          it { is_expected.to be false }
        end
      end

      context 'with :any? expectation qualifier' do
        before do
          constraint.expected = expected_values
          constraint.expectation_qualifier = :any?
        end

        context 'when any expected value is included in the subject' do
          let(:expected_values) { [2, 6] }

          it { is_expected.to be true }
        end

        context 'when none of the expected values are included in the subject' do
          let(:expected_values) { [7, 8] }

          it { is_expected.to be false }
        end
      end

      context 'with :none? expectation qualifier' do
        before do
          constraint.expected = expected_values
          constraint.expectation_qualifier = :none?
        end

        context 'when none of the expected values are included in the subject' do
          let(:expected_values) { [6, 7] }

          it { is_expected.to be true }
        end

        context 'when some expected values are included in the subject' do
          let(:expected_values) { [3, 7] }

          it { is_expected.to be false }
        end
      end

      context 'with :one? expectation qualifier' do
        before do
          constraint.expected = expected_values
          constraint.expectation_qualifier = :one?
        end

        context 'when exactly one expected value is included in the subject' do
          let(:expected_values) { [3, 7] }

          it { is_expected.to be true }
        end

        context 'when more than one expected value is included in the subject' do
          let(:expected_values) { [2, 3] }

          it { is_expected.to be false }
        end

        context 'when none of the expected values are included in the subject' do
          let(:expected_values) { [6, 7] }

          it { is_expected.to be false }
        end
      end
    end

    context 'when subject is a string' do
      let(:subject_value) { 'hello world' }

      context 'with default expectation qualifier (:all?)' do
        before { constraint.expected = expected_substrings }

        context 'when all expected substrings are included in the subject' do
          let(:expected_substrings) { %w[hello world] }

          it { is_expected.to be true }
        end

        context 'when not all expected substrings are included in the subject' do
          let(:expected_substrings) { %w[hello universe] }

          it { is_expected.to be false }
        end
      end

      context 'with :any? expectation qualifier' do
        before do
          constraint.expected = expected_substrings
          constraint.expectation_qualifier = :any?
        end

        context 'when any expected substring is included in the subject' do
          let(:expected_substrings) { %w[universe world] }

          it { is_expected.to be true }
        end

        context 'when none of the expected substrings are included in the subject' do
          let(:expected_substrings) { %w[universe galaxy] }

          it { is_expected.to be false }
        end
      end

      context 'with :none? expectation qualifier' do
        before do
          constraint.expected = expected_substrings
          constraint.expectation_qualifier = :none?
        end

        context 'when none of the expected substrings are included in the subject' do
          let(:expected_substrings) { %w[universe galaxy] }

          it { is_expected.to be true }
        end

        context 'when some expected substrings are included in the subject' do
          let(:expected_substrings) { %w[world galaxy] }

          it { is_expected.to be false }
        end
      end

      context 'with :one? expectation qualifier' do
        before do
          constraint.expected = expected_substrings
          constraint.expectation_qualifier = :one?
        end

        context 'when exactly one expected substring is included in the subject' do
          let(:expected_substrings) { %w[hello galaxy] }

          it { is_expected.to be true }
        end

        context 'when more than one expected substring is included in the subject' do
          let(:expected_substrings) { %w[hello world] }

          it { is_expected.to be false }
        end

        context 'when none of the expected substrings are included in the subject' do
          let(:expected_substrings) { %w[universe galaxy] }

          it { is_expected.to be false }
        end
      end
    end

    context 'when negated' do
      before do
        constraint.negated = true
        constraint.expected = expected_values
      end

      context 'when subject includes expected values' do
        let(:subject_value) { [1, 2, 3] }
        let(:expected_values) { [2] }

        it { is_expected.to be false }
      end

      context 'when subject does not include expected values' do
        let(:subject_value) { [1, 2, 3] }
        let(:expected_values) { [4] }

        it { is_expected.to be true }
      end
    end
  end
end
