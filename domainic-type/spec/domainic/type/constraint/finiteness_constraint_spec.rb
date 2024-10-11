# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/finiteness_constraint'

RSpec.describe Domainic::Type::Constraint::FinitenessConstraint do
  describe '#validate' do
    subject(:validate) { constraint.validate(subject_value) }

    let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

    context 'when the condition is :finite' do
      before { constraint.condition = :finite }

      context 'when the subject is finite' do
        let(:subject_value) { 1 }

        it { is_expected.to be true }
      end

      context 'when the subject is infinite' do
        let(:subject_value) { Float::INFINITY }

        it { is_expected.to be false }
      end

      context 'when the subject is Enumerable and access_qualifier is :all?' do
        before { constraint.access_qualifier = :all? }

        context 'when all elements are finite' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when some elements are not finite' do
          let(:subject_value) { [1, 2, Float::INFINITY] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifier is :any?' do
        before { constraint.access_qualifier = :any? }

        context 'when any element is finite' do
          let(:subject_value) { [1, 2, Float::INFINITY] }

          it { is_expected.to be true }
        end

        context 'when no elements are finite' do
          let(:subject_value) { [Float::INFINITY, Float::INFINITY, Float::INFINITY] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifier is :none?' do
        before { constraint.access_qualifier = :none? }

        context 'when no elements are finite' do
          let(:subject_value) { [Float::INFINITY, Float::INFINITY, Float::INFINITY] }

          it { is_expected.to be true }
        end

        context 'when any element is finite' do
          let(:subject_value) { [1, 2, Float::INFINITY] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifier is :one?' do
        before { constraint.access_qualifier = :one? }

        context 'when one element is finite' do
          let(:subject_value) { [1, Float::INFINITY] }

          it { is_expected.to be true }
        end

        context 'when no elements are finite' do
          let(:subject_value) { [Float::INFINITY, Float::INFINITY, Float::INFINITY] }

          it { is_expected.to be false }
        end

        context 'when multiple elements are finite' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be false }
        end
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is finite' do
          let(:subject_value) { 1 }

          it { is_expected.to be false }
        end

        context 'when the subject is infinite' do
          let(:subject_value) { Float::INFINITY }

          it { is_expected.to be true }
        end
      end
    end

    context 'when the condition is :infinite' do
      before { constraint.condition = :infinite }

      context 'when the subject is finite' do
        let(:subject_value) { 1 }

        it { is_expected.to be false }
      end

      context 'when the subject is infinite' do
        let(:subject_value) { Float::INFINITY }

        it { is_expected.to be true }
      end

      context 'when the subject is Enumerable and access_qualifier is :all?' do
        before { constraint.access_qualifier = :all }

        context 'when all elements are infinite' do
          let(:subject_value) { [Float::INFINITY, Float::INFINITY] }

          it { is_expected.to be true }
        end

        context 'when some elements are not infinite' do
          let(:subject_value) { [1, Float::INFINITY] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifier is :any?' do
        before { constraint.access_qualifier = :any }

        context 'when any element is infinite' do
          let(:subject_value) { [1, 2, Float::INFINITY] }

          it { is_expected.to be true }
        end

        context 'when no elements are infinite' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifier is :none?' do
        before { constraint.access_qualifier = :none }

        context 'when no elements are infinite' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when any element is infinite' do
          let(:subject_value) { [1, 2, Float::INFINITY] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifier is :one?' do
        before { constraint.access_qualifier = :one }

        context 'when one element is infinite' do
          let(:subject_value) { [1, Float::INFINITY] }

          it { is_expected.to be true }
        end

        context 'when no elements are infinite' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be false }
        end

        context 'when multiple elements are infinite' do
          let(:subject_value) { [1, Float::INFINITY, Float::INFINITY, Float::INFINITY] }

          it { is_expected.to be false }
        end
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is finite' do
          let(:subject_value) { 1 }

          it { is_expected.to be true }
        end

        context 'when the subject is infinite' do
          let(:subject_value) { Float::INFINITY }

          it { is_expected.to be false }
        end
      end
    end
  end
end
