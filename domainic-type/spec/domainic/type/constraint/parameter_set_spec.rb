# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/base_constraint'
require 'domainic/type/constraint/parameter_set'

RSpec.describe Domainic::Type::Constraint::ParameterSet do
  let(:base) { instance_double(Domainic::Type::Constraint::BaseConstraint) }

  describe '#[]' do
    subject(:get_parameter) { parameter_set[parameter_name] }

    context 'when a parameter with a matching name exists' do
      before { parameter_set.add(name: parameter_name) }

      let(:parameter_set) { described_class.new(base) }
      let(:parameter_name) { :test }

      it 'is expected to return the parameter' do
        expect(get_parameter).to be_an_instance_of(Domainic::Type::Constraint::Parameter)
          .and(have_attributes(name: parameter_name))
      end
    end
  end

  describe '#add' do
    subject(:add) { parameter_set.add(**parameter_options) }

    let(:parameter_set) { described_class.new(base) }
    let(:parameter_options) { { name: :test } }

    it 'is expected to add a new parameter to the set' do
      expect { add }.to change { parameter_set.instance_variable_get(:@entries).count }.by(1)
    end

    it 'is expected to respond to the parameter name' do
      add
      expect(parameter_set).to respond_to(parameter_options[:name])
    end
  end

  describe '#dup_with_base' do
    subject(:dup_with_base) { parameter_set.dup_with_base(new_base) }

    let(:parameter_set) { described_class.new(base) }
    let(:new_base) { instance_double(Domainic::Type::Constraint::BaseConstraint) }

    it 'is expected to return a new instance of ParameterSet' do
      expect(dup_with_base).to be_an_instance_of(described_class)
    end

    it 'is expected to return a new instance with the new base' do
      expect(dup_with_base.instance_variable_get(:@base)).to eq(new_base)
    end

    it 'is expected to return a new instance with the parameters duplicated' do
      parameter_set.add(name: :test)
      expect(dup_with_base.test.instance_variable_get(:@base)).to eq(new_base)
    end
  end
end
