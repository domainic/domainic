# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/parity_constraint'

RSpec.describe Domainic::Type::Constraint::ParityConstraint do
  describe '#validate' do
    subject(:validate) { constraint.validate(subject_value) }

    let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

    context 'when the condition is :even?' do
      before { constraint.condition = :even }

      context 'when the subject is even' do
        let(:subject_value) { 2 }

        it { is_expected.to be true }
      end

      context 'when the subject is odd' do
        let(:subject_value) { 1 }

        it { is_expected.to be false }
      end

      context 'when the subject is Enumerable and the access_qualifier is :all?' do
        before { constraint.access_qualifier = :all }

        context 'when all elements are even' do
          let(:subject_value) { [2, 4, 6] }

          it { is_expected.to be true }
        end

        context 'when some elements are odd' do
          let(:subject_value) { [2, 3, 6] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :any?' do
        before { constraint.access_qualifier = :any }

        context 'when any elements are even' do
          let(:subject_value) { [1, 3, 6] }

          it { is_expected.to be true }
        end

        context 'when all elements are odd' do
          let(:subject_value) { [1, 3, 5] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :none?' do
        before { constraint.access_qualifier = :none }

        context 'when no elements are even' do
          let(:subject_value) { [1, 3, 5] }

          it { is_expected.to be true }
        end

        context 'when any elements are even' do
          let(:subject_value) { [1, 3, 6] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :one?' do
        before { constraint.access_qualifier = :one }

        context 'when one element is even' do
          let(:subject_value) { [1, 3, 6] }

          it { is_expected.to be true }
        end

        context 'when no elements are even' do
          let(:subject_value) { [1, 3, 5] }

          it { is_expected.to be false }
        end

        context 'when more than one element is even' do
          let(:subject_value) { [1, 2, 6] }

          it { is_expected.to be false }
        end
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is even' do
          let(:subject_value) { 2 }

          it { is_expected.to be false }
        end

        context 'when the subject is odd' do
          let(:subject_value) { 1 }

          it { is_expected.to be true }
        end
      end
    end

    context 'when the condition is :odd?' do
      before { constraint.condition = :odd }

      context 'when the subject is even' do
        let(:subject_value) { 2 }

        it { is_expected.to be false }
      end

      context 'when the subject is odd' do
        let(:subject_value) { 1 }

        it { is_expected.to be true }
      end

      context 'when the subject is Enumerable and the access_qualifier is :all?' do
        before { constraint.access_qualifier = :all }

        context 'when all elements are odd' do
          let(:subject_value) { [1, 3, 5] }

          it { is_expected.to be true }
        end

        context 'when some elements are even' do
          let(:subject_value) { [1, 2, 5] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :any?' do
        before { constraint.access_qualifier = :any }

        context 'when any elements are odd' do
          let(:subject_value) { [2, 4, 5] }

          it { is_expected.to be true }
        end

        context 'when all elements are even' do
          let(:subject_value) { [2, 4, 6] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :none?' do
        before { constraint.access_qualifier = :none }

        context 'when no elements are odd' do
          let(:subject_value) { [2, 4, 6] }

          it { is_expected.to be true }
        end

        context 'when any elements are odd' do
          let(:subject_value) { [2, 4, 5] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and the access_qualifier is :one?' do
        before { constraint.access_qualifier = :one }

        context 'when one element is odd' do
          let(:subject_value) { [2, 3, 6] }

          it { is_expected.to be true }
        end

        context 'when no elements are odd' do
          let(:subject_value) { [2, 4, 6] }

          it { is_expected.to be false }
        end

        context 'when more than one element is odd' do
          let(:subject_value) { [1, 3, 6] }

          it { is_expected.to be false }
        end
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is even' do
          let(:subject_value) { 2 }

          it { is_expected.to be true }
        end

        context 'when the subject is odd' do
          let(:subject_value) { 1 }

          it { is_expected.to be false }
        end
      end
    end
  end
end
