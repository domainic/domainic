# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/instance_of_constraint'

RSpec.describe Domainic::Type::Constraint::InstanceOfConstraint do
  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(actual_value) }

    let(:constraint) { described_class.new(:self).expecting(expected_value) }

    context 'with classes' do
      let(:expected_value) { String }

      context 'when instance matches the expected class' do
        let(:actual_value) { 'test' }

        it { is_expected.to be true }
      end

      context 'when instance does not match the expected class' do
        let(:actual_value) { 42 }

        it { is_expected.to be false }
      end
    end

    context 'with modules' do
      let(:expected_value) { Enumerable }

      context 'when instance matches the expected module' do
        let(:actual_value) { [] } # Arrays include Enumerable

        it { is_expected.to be true }
      end

      context 'when instance does not match the expected module' do
        let(:actual_value) { 'string' }

        it { is_expected.to be false }
      end
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(expected_value) }
    let(:expected_value) { String }

    it 'is expected to return a description of the instance type' do
      expect(short_description).to eq('instance of String')
    end
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) { constraint.short_violation_description }

    let(:constraint) { described_class.new(:self).expecting(expected_value) }
    let(:expected_value) { String }

    it 'is expected to return a description of the failure reason' do
      expect(short_violation_description).to eq('not an instance of String')
    end
  end
end
