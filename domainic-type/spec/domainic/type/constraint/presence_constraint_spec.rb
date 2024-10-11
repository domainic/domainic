# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/presence_constraint'

RSpec.describe Domainic::Type::Constraint::PresenceConstraint do
  describe '#validate' do
    subject(:validate) { constraint.validate(subject_value) }

    let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

    context 'when the condition is :absent?' do
      before { constraint.condition = :absent }

      context 'when the subject is nil' do
        let(:subject_value) { nil }

        it { is_expected.to be true }
      end

      context 'when the subject is empty' do
        let(:subject_value) { '' }

        it { is_expected.to be true }
      end

      context 'when the subject is not empty or nil' do
        let(:subject_value) { 'a' }

        it { is_expected.to be false }
      end

      context 'when the subject is an Enumerable and access_qualifier is :all?' do
        before { constraint.access_qualifier = :all }

        context 'when all elements are nil' do
          let(:subject_value) { [nil, nil, nil] }

          it { is_expected.to be true }
        end

        context 'when all elements are empty' do
          let(:subject_value) { ['', '', ''] }

          it { is_expected.to be true }
        end

        context 'when all elements are not empty or nil' do
          let(:subject_value) { %w[a b c] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is an Enumerable and access_qualifier is :any?' do
        before { constraint.access_qualifier = :any }

        context 'when any element is nil' do
          let(:subject_value) { [nil, nil, nil] }

          it { is_expected.to be true }
        end

        context 'when any element is empty' do
          let(:subject_value) { ['', '', ''] }

          it { is_expected.to be true }
        end

        context 'when no elements are empty or nil' do
          let(:subject_value) { %w[a b c] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is an Enumerable and access_qualifier is :none?' do
        before { constraint.access_qualifier = :none }

        context 'when no elements are nil' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end

        context 'when no elements are empty' do
          let(:subject_value) { %w[a b c] }

          it { is_expected.to be true }
        end

        context 'when any elements are empty or nil' do
          let(:subject_value) { [nil, '', 1] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is an Enumerable and access_qualifier is :one?' do
        before { constraint.access_qualifier = :one }

        context 'when one element is nil' do
          let(:subject_value) { [nil, 1, 2] }

          it { is_expected.to be true }
        end

        context 'when one element is empty' do
          let(:subject_value) { ['', 1, 2] }

          it { is_expected.to be true }
        end

        context 'when more than one element is empty or nil' do
          let(:subject_value) { [nil, '', 1] }

          it { is_expected.to be false }
        end
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is nil' do
          let(:subject_value) { nil }

          it { is_expected.to be false }
        end

        context 'when the subject is empty' do
          let(:subject_value) { '' }

          it { is_expected.to be false }
        end

        context 'when the subject is not empty or nil' do
          let(:subject_value) { 'a' }

          it { is_expected.to be true }
        end
      end
    end

    context 'when the condition is :present?' do
      before { constraint.condition = :present }

      context 'when the subject is nil' do
        let(:subject_value) { nil }

        it { is_expected.to be false }
      end

      context 'when the subject is empty' do
        let(:subject_value) { '' }

        it { is_expected.to be false }
      end

      context 'when the subject is not empty or nil' do
        let(:subject_value) { 'a' }

        it { is_expected.to be true }
      end

      context 'when the subject is an Enumerable and access_qualifier is :all?' do
        before { constraint.access_qualifier = :all }

        context 'when all elements are nil' do
          let(:subject_value) { [nil, nil, nil] }

          it { is_expected.to be false }
        end

        context 'when all elements are empty' do
          let(:subject_value) { ['', '', ''] }

          it { is_expected.to be false }
        end

        context 'when all elements are not empty or nil' do
          let(:subject_value) { %w[a b c] }

          it { is_expected.to be true }
        end
      end

      context 'when the subject is an Enumerable and access_qualifier is :any?' do
        before { constraint.access_qualifier = :any }

        context 'when any element is nil' do
          let(:subject_value) { [nil, nil, nil] }

          it { is_expected.to be false }
        end

        context 'when any element is empty' do
          let(:subject_value) { ['', '', ''] }

          it { is_expected.to be false }
        end

        context 'when no elements are empty or nil' do
          let(:subject_value) { %w[a b c] }

          it { is_expected.to be true }
        end
      end

      context 'when the subject is an Enumerable and access_qualifier is :none?' do
        before { constraint.access_qualifier = :none }

        context 'when no elements are nil' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be false }
        end

        context 'when no elements are empty' do
          let(:subject_value) { %w[a b c] }

          it { is_expected.to be false }
        end
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is nil' do
          let(:subject_value) { nil }

          it { is_expected.to be true }
        end

        context 'when the subject is empty' do
          let(:subject_value) { '' }

          it { is_expected.to be true }
        end

        context 'when the subject is not empty or nil' do
          let(:subject_value) { 'a' }

          it { is_expected.to be false }
        end
      end
    end
  end
end
