# frozen_string_literal: true

# spec/domainic/type/constraint/type_constraint_spec.rb

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/type_constraint'

RSpec.describe Domainic::Type::Constraint::TypeConstraint do
  subject(:validate) { constraint.validate(subject_value) }

  let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

  describe '#validate' do
    context 'when expected is a single type' do
      before { constraint.expected = expected_type }

      context 'when subject is of the expected type' do
        let(:expected_type) { String }
        let(:subject_value) { 'hello' }

        it { is_expected.to be true }
      end

      context 'when subject is not of the expected type' do
        let(:expected_type) { String }
        let(:subject_value) { 123 }

        it { is_expected.to be false }
      end
    end

    context 'when expected is an array of types' do
      before { constraint.expected = expected_types }

      context 'with default expectation qualifier (:all?)' do
        let(:expected_types) { [Numeric, Integer] }

        context 'when subject is of all expected types' do
          let(:subject_value) { 123 } # Integer is a Numeric

          it { is_expected.to be true }
        end

        context 'when subject is not of all expected types' do
          let(:subject_value) { 123.45 } # Float is Numeric but not Integer

          it { is_expected.to be false }
        end
      end

      context 'with :any? expectation qualifier' do
        before { constraint.expectation_qualifier = :any? }

        let(:expected_types) { [String, Numeric] }

        context 'when subject is of any expected type (String)' do
          let(:subject_value) { 'hello' }

          it { is_expected.to be true }
        end

        context 'when subject is of any expected type (Numeric)' do
          let(:subject_value) { 123 }

          it { is_expected.to be true }
        end

        context 'when subject is of none of the expected types' do
          let(:subject_value) { :symbol }

          it { is_expected.to be false }
        end
      end

      context 'with :none? expectation qualifier' do
        before { constraint.expectation_qualifier = :none? }

        let(:expected_types) { [String, Numeric] }

        context 'when subject is of none of the expected types' do
          let(:subject_value) { :symbol }

          it { is_expected.to be true }
        end

        context 'when subject is of any expected type' do
          let(:subject_value) { 'hello' }

          it { is_expected.to be false }
        end
      end

      context 'with :one? expectation qualifier' do
        before { constraint.expectation_qualifier = :one? }

        let(:expected_types) { [Numeric, Integer] }

        context 'when subject is of exactly one expected type' do
          let(:subject_value) { 123.45 } # Float is Numeric but not Integer

          it { is_expected.to be true }
        end

        context 'when subject is of more than one expected type' do
          let(:subject_value) { 123 } # Integer is both Integer and Numeric

          it { is_expected.to be false }
        end

        context 'when subject is of none of the expected types' do
          let(:subject_value) { 'hello' }

          it { is_expected.to be false }
        end
      end
    end

    context 'when expected is a Domainic::Type' do
      let(:custom_type) do
        klass = Class.new(Domainic::Type::BaseType) do
          def validate(value)
            value == 'custom'
          end
        end
        klass.new
      end

      before { constraint.expected = custom_type }

      context 'when subject satisfies the custom type' do
        let(:subject_value) { 'custom' }

        it { is_expected.to be true }
      end

      context 'when subject does not satisfy the custom type' do
        let(:subject_value) { 'not custom' }

        it { is_expected.to be false }
      end
    end

    context 'when negated' do
      before do
        constraint.negated = true
        constraint.expected = expected_type
      end

      context 'when subject is of the expected type' do
        let(:expected_type) { String }
        let(:subject_value) { 'hello' }

        it { is_expected.to be false }
      end

      context 'when subject is not of the expected type' do
        let(:expected_type) { String }
        let(:subject_value) { 123 }

        it { is_expected.to be true }
      end
    end
  end
end
