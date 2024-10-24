# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/base_constraint'

RSpec.describe Domainic::Type::Constraint::BaseConstraint do
  let(:type) { instance_double(Domainic::Type::BaseType) }

  describe '.parameter' do
    subject(:parameter) { constraint_class.parameter(:test) }

    let(:constraint_class) { Class.new(described_class) }

    it {
      expect { parameter }.to(
        change { constraint_class.parameters.instance_variable_get(:@entries).count }.by(1)
      )
    }
  end

  describe '.parameters' do
    subject(:parameters) { described_class.parameters }

    it { is_expected.to be_an_instance_of(Domainic::Type::Constraint::Specification::ParameterSet) }
  end

  describe '#accessor' do
    subject(:accessor) { constraint.accessor }

    let(:constraint) { described_class.new(type) }

    it { is_expected.to eq(:self) }

    context 'when set' do
      before { constraint.accessor = expected_value }

      let(:expected_value) { described_class::VALID_ACCESSORS.reject { |i| i == constraint.accessor_default }.sample }

      it { is_expected.to eq(expected_value) }
    end
  end

  describe '#accessor=' do
    subject(:set_accessor) { constraint.accessor = expected_value }

    let(:constraint) { described_class.new(type) }
    let(:expected_value) { described_class::VALID_ACCESSORS.reject { |i| i == constraint.accessor_default }.sample }

    it { expect { set_accessor }.to change(constraint, :accessor).to(expected_value) }
  end

  describe '#accessor_default' do
    subject(:accessor_default) { constraint.accessor_default }

    let(:constraint) { described_class.new(type) }

    it { is_expected.to eq(:self) }
  end

  describe '#dup_with_base' do
    subject(:dup_with_base) { constraint.dup_with_base(new_base) }

    let(:constraint) { described_class.new(type) }
    let(:new_base) { instance_double(Domainic::Type::BaseType) }

    it 'is expected to duplicate the constraint with the new base' do
      expect(dup_with_base.instance_variable_get(:@base)).to eq(new_base)
    end

    it 'is expected to duplicate the constraint with the same parameters' do
      duped = dup_with_base
      expect(duped.parameters.instance_variable_get(:@base)).to eq(duped)
    end
  end

  describe '#negated' do
    subject(:negated) { constraint.negated }

    let(:constraint) { described_class.new(type) }

    it { is_expected.to be false }

    context 'when set' do
      before { constraint.negated = expected_value }

      let(:expected_value) { true }

      it { is_expected.to eq(expected_value) }
    end
  end

  describe '#negated=' do
    subject(:set_negated) { constraint.negated = expected_value }

    let(:constraint) { described_class.new(type) }
    let(:expected_value) { true }

    it { expect { set_negated }.to change(constraint, :negated).to(expected_value) }
  end

  describe '#negated_default' do
    subject(:negated_default) { constraint.negated_default }

    let(:constraint) { described_class.new(type) }

    it { is_expected.to be false }
  end

  describe '#initialize' do
    subject(:new_instance) { constraint_class.new(type, **options) }

    let(:constraint_class) { described_class }
    let(:options) { {} }

    it 'is expected to initialize with the base type' do
      expect(new_instance.instance_variable_get(:@base)).to eq(type)
    end

    it 'is expected to initialize with parameters' do
      expect(new_instance.parameters).to be_an_instance_of(Domainic::Type::Constraint::Specification::ParameterSet)
    end

    context 'when name is provided' do
      let(:options) { { name: 'test' } }

      it { is_expected.to have_attributes(name: options[:name].to_sym) }
    end

    context 'when name is not provided' do
      it { is_expected.to have_attributes(name: :base) }
    end

    context 'when parameters are provided' do
      let(:constraint_class) do
        Class.new(described_class) do
          def self.name
            'TestConstraint'
          end

          parameters.add(name: :test)
        end
      end

      let(:options) { { test: 'test' } }

      it 'is expected to set the parameter value' do
        expect(new_instance.parameters.test.value).to eq(options[:test])
      end
    end
  end
end
