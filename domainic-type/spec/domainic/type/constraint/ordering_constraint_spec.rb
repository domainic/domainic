# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/ordering_constraint'

RSpec.describe Domainic::Type::Constraint::OrderingConstraint do
  describe '#validate' do
    subject(:validate) { constraint.validate(subject_value) }

    let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }
    let(:ordered) { %w[a b c] }
    let(:unordered) { %w[c a b] }

    context 'when the condition is :ordered' do
      before { constraint.condition = :ordered }

      context 'when the subject is ordered' do
        let(:subject_value) { ordered }

        it { is_expected.to be true }
      end

      context 'when the subject is not ordered' do
        let(:subject_value) { unordered }

        it { is_expected.to be false }
      end

      context 'when the subject is a String and ordered' do
        let(:subject_value) { 'abc' }

        it { is_expected.to be true }
      end

      context 'when the subject is a String and not ordered' do
        let(:subject_value) { 'cab' }

        it { is_expected.to be false }
      end

      context 'when the subject does not respond to sort' do
        let(:subject_value) { 123 }

        it { is_expected.to be false }
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is ordered' do
          let(:subject_value) { ordered }

          it { is_expected.to be false }
        end

        context 'when the subject is not ordered' do
          let(:subject_value) { unordered }

          it { is_expected.to be true }
        end
      end

      context 'when the constraint is reversed' do
        before { constraint.reversed = true }

        context 'when the subject is reverse ordered' do
          let(:subject_value) { ordered.reverse }

          it { is_expected.to be true }
        end

        context 'when the subject is ordered' do
          let(:subject_value) { ordered }

          it { is_expected.to be false }
        end

        context 'when the subject is unordered' do
          let(:subject_value) { unordered }

          it { is_expected.to be false }
        end
      end
    end

    context 'when the condition is :unordered' do
      before { constraint.condition = :unordered }

      context 'when the subject is ordered' do
        let(:subject_value) { ordered }

        it { is_expected.to be false }
      end

      context 'when the subject is not ordered' do
        let(:subject_value) { unordered }

        it { is_expected.to be true }
      end

      context 'when the subject is a String and ordered' do
        let(:subject_value) { 'abc' }

        it { is_expected.to be false }
      end

      context 'when the subject is a String and not ordered' do
        let(:subject_value) { 'cab' }

        it { is_expected.to be true }
      end

      context 'when the subject does not respond to sort' do
        let(:subject_value) { 123 }

        it { is_expected.to be false }
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is ordered' do
          let(:subject_value) { ordered }

          it { is_expected.to be true }
        end

        context 'when the subject is not ordered' do
          let(:subject_value) { unordered }

          it { is_expected.to be false }
        end
      end

      context 'when the constraint is reversed' do
        before { constraint.reversed = true }

        context 'when the subject is reverse ordered' do
          let(:subject_value) { ordered.reverse }

          it { is_expected.to be false }
        end

        context 'when the subject is ordered' do
          let(:subject_value) { ordered }

          it { is_expected.to be true }
        end

        context 'when the subject is unordered' do
          let(:subject_value) { unordered }

          it { is_expected.to be true }
        end
      end
    end
  end
end
