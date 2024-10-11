# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/population_constraint'

RSpec.describe Domainic::Type::Constraint::PopulationConstraint do
  describe '#validate' do
    subject(:validate) { constraint.validate(subject_value) }

    let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

    context 'when the condition is :empty?' do
      before { constraint.condition = :empty }

      context 'when the subject is empty' do
        let(:subject_value) { [] }

        it { is_expected.to be true }
      end

      context 'when the subject is not empty' do
        let(:subject_value) { [1, 2, 3] }

        it { is_expected.to be false }
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is empty' do
          let(:subject_value) { [] }

          it { is_expected.to be false }
        end

        context 'when the subject is not empty' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be true }
        end
      end
    end

    context 'when the condition is :populated?' do
      before { constraint.condition = :populated }

      context 'when the subject is empty' do
        let(:subject_value) { [] }

        it { is_expected.to be false }
      end

      context 'when the subject is not empty' do
        let(:subject_value) { [1, 2, 3] }

        it { is_expected.to be true }
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is empty' do
          let(:subject_value) { [] }

          it { is_expected.to be true }
        end

        context 'when the subject is not empty' do
          let(:subject_value) { [1, 2, 3] }

          it { is_expected.to be false }
        end
      end
    end
  end
end
