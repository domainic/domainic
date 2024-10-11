# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/uniqueness_constraint'

RSpec.describe Domainic::Type::Constraint::UniquenessConstraint do
  describe '#validate' do
    subject(:validate) { constraint.validate(subject_value) }

    let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }
    let(:duplicative) { %w[a a b] }
    let(:unique) { %w[a b c] }

    context 'when the condition is :duplicative' do
      before { constraint.condition = :duplicative }

      context 'when the subject is duplicative' do
        let(:subject_value) { duplicative }

        it { is_expected.to be true }
      end

      context 'when the subject is unique' do
        let(:subject_value) { unique }

        it { is_expected.to be false }
      end

      context 'when the subject is a String and duplicative' do
        let(:subject_value) { 'aabc' }

        it { is_expected.to be true }
      end

      context 'when the subject is a String and unique' do
        let(:subject_value) { 'abc' }

        it { is_expected.to be false }
      end

      context 'when the subject does not respond to uniq' do
        let(:subject_value) { 123 }

        it { is_expected.to be false }
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is duplicative' do
          let(:subject_value) { duplicative }

          it { is_expected.to be false }
        end

        context 'when the subject is unique' do
          let(:subject_value) { unique }

          it { is_expected.to be true }
        end
      end
    end

    context 'when the condition is :unique' do
      before { constraint.condition = :unique }

      context 'when the subject is duplicative' do
        let(:subject_value) { duplicative }

        it { is_expected.to be false }
      end

      context 'when the subject is unique' do
        let(:subject_value) { unique }

        it { is_expected.to be true }
      end

      context 'when the subject is a String and duplicative' do
        let(:subject_value) { 'aab' }

        it { is_expected.to be false }
      end

      context 'when the subject is a String and unique' do
        let(:subject_value) { 'abc' }

        it { is_expected.to be true }
      end

      context 'when the subject does not respond to uniq' do
        let(:subject_value) { 123 }

        it { is_expected.to be false }
      end

      context 'when the constraint is negated' do
        before { constraint.negated = true }

        context 'when the subject is duplicative' do
          let(:subject_value) { duplicative }

          it { is_expected.to be true }
        end

        context 'when the subject is unique' do
          let(:subject_value) { unique }

          it { is_expected.to be false }
        end
      end
    end
  end
end
