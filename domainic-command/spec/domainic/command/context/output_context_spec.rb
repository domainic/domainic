# frozen_string_literal: true

require 'spec_helper'
require 'domainic/command/context/output_context'

RSpec.describe Domainic::Command::Context::OutputContext do
  describe '.field' do
    subject(:field) { output_context_class.field(name, *type_validator_and_description, **options) }

    let(:output_context_class) { Class.new(described_class) }
    let(:name) { :test_return }
    let(:type_validator_and_description) { [] }
    let(:options) { {} }

    it 'is expected to create an attribute' do
      expect { field }.to change { output_context_class.send(:attributes).all.count }.by(1)
    end

    context 'when given a type validator' do
      let(:type_validator_and_description) { [String] }
      let(:instance) { output_context_class.new(test_return: 'test') }

      it 'is expected to validate the type' do
        field
        expect(instance.test_return).to eq('test')
      end

      context 'when given an invalid value' do
        let(:instance) { output_context_class.new(test_return: 1) }

        it 'is expected to raise an ArgumentError' do
          field
          expect { instance }.to raise_error(ArgumentError)
        end
      end
    end

    context 'when given a description' do
      let(:type_validator_and_description) { ['Test description'] }

      it 'is expected to set the description' do
        field
        expect(output_context_class.send(:attributes)[:test_return].description).to eq('Test description')
      end
    end
  end
end
