# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/polarity_constraint'

RSpec.describe Domainic::Type::Constraint::PolarityConstraint do
  describe '#validate' do
    subject(:validate) { constraint.validate(subject_value) }

    let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

    context 'when the condition is :positive?' do
      before { constraint.condition = :positive }

      context 'when the subject is positive' do
        let(:subject_value) { 1 }

        it { is_expected.to be true }
      end

      context 'when the subject is negative' do
        let(:subject_value) { -1 }

        it { is_expected.to be false }
      end

      context 'when the subject is Enumerable and the access_qualifier is :all?' do
        before { constraint.access_qualifier = :all }

        context 'when all values are positive' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when some values are negative' do
          let(:subject_value) { [1, 2, -3] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :any?' do
        before { constraint.access_qualifier = :any }

        context 'when some values are positive' do
          let(:subject_value) { [1, -2] }

          it { is_expected.to be true }
        end

        context 'when no values are positive' do
          let(:subject_value) { [-1, -2] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :none?' do
        before { constraint.access_qualifier = :none }

        context 'when some values are positive' do
          let(:subject_value) { [1, -2] }

          it { is_expected.to be false }
        end

        context 'when no values are positive' do
          let(:subject_value) { [-1, -2] }

          it { is_expected.to be true }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :one?' do
        before { constraint.access_qualifier = :one }

        context 'when one value is positive' do
          let(:subject_value) { [1, -1] }

          it { is_expected.to be true }
        end

        context 'when no value is positive' do
          let(:subject_value) { [-1, -2] }

          it { is_expected.to be false }
        end

        context 'when more than one value is positive' do
          let(:subject_value) { [1, 2] }

          it { is_expected.to be false }
        end
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is positive' do
          let(:subject_value) { 1 }

          it { is_expected.to be false }
        end

        context 'when the subject is negative' do
          let(:subject_value) { -1 }

          it { is_expected.to be true }
        end
      end
    end

    context 'when the condition is :negative?' do
      before { constraint.condition = :negative }

      context 'when the subject is positive' do
        let(:subject_value) { 1 }

        it { is_expected.to be false }
      end

      context 'when the subject is negative' do
        let(:subject_value) { -1 }

        it { is_expected.to be true }
      end

      context 'when the subject is Enumerable and the access_qualifier is :all?' do
        before { constraint.access_qualifier = :all }

        context 'when all values are negative' do
          let(:subject_value) { [-1, -2, -3] }

          it { is_expected.to be true }
        end

        context 'when some values are positive' do
          let(:subject_value) { [1, 2, -3] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :any?' do
        before { constraint.access_qualifier = :any }

        context 'when some values are negative' do
          let(:subject_value) { [1, -2] }

          it { is_expected.to be true }
        end

        context 'when no values are negative' do
          let(:subject_value) { [1, 2] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :none?' do
        before { constraint.access_qualifier = :none }

        context 'when some values are negative' do
          let(:subject_value) { [1, -2] }

          it { is_expected.to be false }
        end

        context 'when no values are negative' do
          let(:subject_value) { [1, 2] }

          it { is_expected.to be true }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :one?' do
        before { constraint.access_qualifier = :one }

        context 'when one value is negative' do
          let(:subject_value) { [1, -1] }

          it { is_expected.to be true }
        end

        context 'when no value is negative' do
          let(:subject_value) { [1, 2] }

          it { is_expected.to be false }
        end

        context 'when more than one value is negative' do
          let(:subject_value) { [-1, -2] }

          it { is_expected.to be false }
        end
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is positive' do
          let(:subject_value) { 1 }

          it { is_expected.to be true }
        end

        context 'when the subject is negative' do
          let(:subject_value) { -1 }

          it { is_expected.to be false }
        end
      end
    end
  end
end
