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

    it { is_expected.to be_an_instance_of(Domainic::Type::Constraint::ParameterSet) }
  end

  describe '#initialize' do
    subject(:new_instance) { constraint_class.new(type, **options) }

    let(:constraint_class) { described_class }
    let(:options) { {} }

    it 'is expected to initialize with the base type' do
      expect(new_instance.instance_variable_get(:@base)).to eq(type)
    end

    it 'is expected to initialize with parameters' do
      expect(new_instance.parameters).to be_an_instance_of(Domainic::Type::Constraint::ParameterSet)
    end

    context 'when name and description is provided' do
      let(:options) { { name: 'test', description: 'A test constraint' } }

      it { is_expected.to have_attributes(name: options[:name].to_sym, description: options[:description]) }
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
