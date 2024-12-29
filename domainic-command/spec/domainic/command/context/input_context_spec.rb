# frozen_string_literal: true

require 'spec_helper'
require 'domainic/command/context/input_context'

RSpec.describe Domainic::Command::Context::InputContext do
  describe '.argument' do
    subject(:argument) { input_context_class.argument(name, *type_validator_and_description, **options) }

    let(:input_context_class) { Class.new(described_class) }
    let(:name) { :test_argument }
    let(:type_validator_and_description) { [] }
    let(:options) { {} }

    it 'is expected to create an attribute' do
      expect { argument }.to change { input_context_class.send(:attributes).all.count }.by(1)
    end

    context 'when given a type validator' do
      let(:type_validator_and_description) { [String] }
      let(:instance) { input_context_class.new(test_argument: 'test') }

      it 'is expected to validate the type' do
        argument
        expect(instance.test_argument).to eq('test')
      end

      context 'when given an invalid value' do
        let(:instance) { input_context_class.new(test_argument: 1) }

        it 'is expected to raise an ArgumentError' do
          argument
          expect { instance }.to raise_error(ArgumentError)
        end
      end
    end

    context 'when given a description' do
      let(:type_validator_and_description) { ['Test description'] }

      it 'is expected to set the description' do
        argument
        expect(input_context_class.send(:attributes)[:test_argument].description).to eq('Test description')
      end
    end
  end
end
