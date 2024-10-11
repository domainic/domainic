# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/mutability_constraint'

RSpec.describe Domainic::Type::Constraint::MutabilityConstraint do
  describe '#validate' do
    subject(:validate) { constraint.validate(subject_value) }

    let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

    context 'when the condition is :immutable' do
      before { constraint.condition = :immutable }

      context 'when the subject is frozen' do
        let(:subject_value) { Object.new.freeze }

        it { is_expected.to be true }
      end

      context 'when the subject is not frozen' do
        let(:subject_value) { Object.new }

        it { is_expected.to be false }
      end

      context 'when the subject is Enumerable and access_qualifer is :all?' do
        before { constraint.access_qualifier = :all }

        context 'when all elements are frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new.freeze] }

          it { is_expected.to be true }
        end

        context 'when not all elements are frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifer is :any?' do
        before { constraint.access_qualifier = :any }

        context 'when any elements are frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new] }

          it { is_expected.to be true }
        end

        context 'when no elements are frozen' do
          let(:subject_value) { [Object.new, Object.new] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifier is :none?' do
        before { constraint.access_qualifier = :none }

        context 'when no elements are frozen' do
          let(:subject_value) { [Object.new, Object.new] }

          it { is_expected.to be true }
        end

        context 'when any elements are frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifier is :one' do
        before { constraint.access_qualifier = :one }

        context 'when one element is frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new] }

          it { is_expected.to be true }
        end

        context 'when no elements are frozen' do
          let(:subject_value) { [Object.new, Object.new] }

          it { is_expected.to be false }
        end

        context 'when more than one element is frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new.freeze] }

          it { is_expected.to be false }
        end
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is frozen' do
          let(:subject_value) { Object.new.freeze }

          it { is_expected.to be false }
        end

        context 'when the subject is not frozen' do
          let(:subject_value) { Object.new }

          it { is_expected.to be true }
        end
      end
    end

    context 'when the condition is :mutable' do
      before { constraint.condition = :mutable }

      context 'when the subject is not frozen' do
        let(:subject_value) { Object.new }

        it { is_expected.to be true }
      end

      context 'when the subject is frozen' do
        let(:subject_value) { Object.new.freeze }

        it { is_expected.to be false }
      end

      context 'when the subject is Enumerable and access_qualifier is :all?' do
        before { constraint.access_qualifier = :all }

        context 'when all elements are not frozen' do
          let(:subject_value) { [Object.new, Object.new] }

          it { is_expected.to be true }
        end

        context 'when not all elements are not frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifier is :any?' do
        before { constraint.access_qualifier = :any }

        context 'when any elements are not frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new] }

          it { is_expected.to be true }
        end

        context 'when no elements are not frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new.freeze] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifier is :none?' do
        before { constraint.access_qualifier = :none }

        context 'when no elements are not frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new.freeze] }

          it { is_expected.to be true }
        end

        context 'when any elements are not frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new] }

          it { is_expected.to be false }
        end
      end

      context 'when the subject is Enumerable and access_qualifier is :one' do
        before { constraint.access_qualifier = :one }

        context 'when one element is not frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new] }

          it { is_expected.to be true }
        end

        context 'when no elements are not frozen' do
          let(:subject_value) { [Object.new.freeze, Object.new.freeze] }

          it { is_expected.to be false }
        end

        context 'when more than one element is not frozen' do
          let(:subject_value) { [Object.new, Object.new] }

          it { is_expected.to be false }
        end
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is not frozen' do
          let(:subject_value) { Object.new }

          it { is_expected.to be false }
        end

        context 'when the subject is frozen' do
          let(:subject_value) { Object.new.freeze }

          it { is_expected.to be true }
        end
      end
    end
  end
end
