# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/constraints/method_presence_constraint'

RSpec.describe Domainic::Type::Constraint::MethodPresenceConstraint do
  let(:test_object) do
    Class.new do
      def test_method; end
    end.new
  end

  describe '#satisfied?' do
    subject(:satisfied?) { constraint.satisfied?(test_object) }

    let(:constraint) { described_class.new(:self).expecting(expectation) }

    context 'when the object responds to the method' do
      let(:expectation) { :test_method }

      it { is_expected.to be true }
    end

    context 'when the object does not respond to the method' do
      let(:expectation) { :missing_method }

      it { is_expected.to be false }
    end
  end

  describe '#short_description' do
    subject(:short_description) { constraint.short_description }

    let(:constraint) { described_class.new(:self).expecting(:test_method) }

    it { is_expected.to eq('responding to test_method') }
  end

  describe '#short_violation_description' do
    subject(:short_violation_description) do
      constraint.satisfied?(test_object)
      constraint.short_violation_description
    end

    let(:constraint) { described_class.new(:self).expecting(:missing_method) }

    it { is_expected.to eq('not responding to missing_method') }
  end
end
