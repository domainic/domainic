# frozen_string_literal: true

# spec/domainic/type/constraint/match_constraint_spec.rb

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/match_constraint'

RSpec.describe Domainic::Type::Constraint::MatchConstraint do
  subject(:validate) { constraint.validate(subject_value) }

  let(:constraint) { described_class.new(instance_double(Domainic::Type::BaseType)) }

  describe '#validate' do
    context 'when expected is a single pattern' do
      before { constraint.expected = expected_pattern }

      context 'when subject matches the expected pattern' do
        let(:subject_value) { 'hello world' }
        let(:expected_pattern) { /hello/ }

        it { is_expected.to be true }
      end

      context 'when subject does not match the expected pattern' do
        let(:subject_value) { 'goodbye world' }
        let(:expected_pattern) { /hello/ }

        it { is_expected.to be false }
      end
    end

    context 'when expected is an array of patterns' do
      before { constraint.expected = expected_patterns }

      context 'with default expectation qualifier (:all?)' do
        let(:expected_patterns) { [/hello/, /world/] }

        before { constraint.expectation_qualifier = :all? }

        context 'when subject matches all expected patterns' do
          let(:subject_value) { 'hello world' }

          it { is_expected.to be true }
        end

        context 'when subject does not match all expected patterns' do
          let(:subject_value) { 'hello there' }

          it { is_expected.to be false }
        end
      end

      context 'with :any? expectation qualifier' do
        let(:expected_patterns) { patterns }

        before { constraint.expectation_qualifier = :any? }

        context 'when subject matches any expected pattern' do
          let(:patterns) { [/goodbye/, /hello/] }
          let(:subject_value) { 'hello there' }

          it { is_expected.to be true }
        end

        context 'when subject does not match any expected pattern' do
          let(:patterns) { [/goodbye/, /farewell/] }
          let(:subject_value) { 'hello there' }

          it { is_expected.to be false }
        end
      end

      context 'with :none? expectation qualifier' do
        let(:expected_patterns) { patterns }

        before { constraint.expectation_qualifier = :none? }

        context 'when subject matches none of the expected patterns' do
          let(:patterns) { [/goodbye/, /farewell/] }
          let(:subject_value) { 'hello there' }

          it { is_expected.to be true }
        end

        context 'when subject matches any expected pattern' do
          let(:patterns) { [/hello/, /farewell/] }
          let(:subject_value) { 'hello there' }

          it { is_expected.to be false }
        end
      end

      context 'with :one? expectation qualifier' do
        let(:expected_patterns) { patterns }

        before { constraint.expectation_qualifier = :one? }

        context 'when subject matches exactly one expected pattern' do
          let(:patterns) { [/hello/, /goodbye/] }
          let(:subject_value) { 'hello world' }

          it { is_expected.to be true }
        end

        context 'when subject matches more than one expected pattern' do
          let(:patterns) { [/hello/, /world/] }
          let(:subject_value) { 'hello world' }

          it { is_expected.to be false }
        end

        context 'when subject matches none of the expected patterns' do
          let(:patterns) { [/goodbye/, /farewell/] }
          let(:subject_value) { 'hello world' }

          it { is_expected.to be false }
        end
      end
    end

    context 'when subject or expected is nil' do
      context 'when subject is nil' do
        let(:subject_value) { nil }

        context 'when expected is a pattern' do
          before { constraint.expected = /hello/ }

          it { is_expected.to be false }
        end

        context 'when expected is nil' do
          before { constraint.expected = nil }

          it { is_expected.to be false }
        end
      end

      context 'when expected is nil' do
        let(:subject_value) { 'hello world' }

        before { constraint.expected = nil }

        it { is_expected.to be false }
      end
    end

    context 'when subject and expected are of different types' do
      let(:subject_value) { 'hello world' }

      before { constraint.expected = 123 }

      it { is_expected.to be false }
    end

    context 'when negated' do
      before do
        constraint.negated = true
        constraint.expected = expected_pattern
      end

      let(:subject_value) { 'hello world' }

      context 'when subject matches expected pattern' do
        let(:expected_pattern) { /hello/ }

        it { is_expected.to be false }
      end

      context 'when subject does not match expected pattern' do
        let(:expected_pattern) { /goodbye/ }

        it { is_expected.to be true }
      end
    end
  end
end
