# frozen_string_literal: true

require 'spec_helper'
require 'domainic/command/class_methods'

RSpec.describe Domainic::Command::ClassMethods do
  let(:test_class) do
    Class.new do
      extend Domainic::Command::ClassMethods
    end
  end

  describe '.accepts_arguments_matching' do
    subject(:accept_arguments) { test_class.accepts_arguments_matching(input_context_class) }

    context 'when given a valid input context class' do
      let(:input_context_class) do
        Class.new(Domainic::Command::Context::InputContext) do
          argument :name, String, required: true
        end
      end

      it 'is expected to set the input context class' do
        expect { accept_arguments }
          .to change { test_class.send(:input_context_class).superclass }
          .to(input_context_class)
      end
    end

    context 'when given an invalid input context class', rbs: :skip do
      let(:input_context_class) { Class.new }

      it 'is expected to raise an ArgumentError' do
        expect { accept_arguments }
          .to raise_error(ArgumentError, /must be a subclass of Context::InputContext/)
      end
    end
  end

  describe '.returns_data_matching' do
    subject(:accept_output) { test_class.returns_data_matching(output_context_class) }

    context 'when given a valid output context class' do
      let(:output_context_class) do
        Class.new(Domainic::Command::Context::OutputContext) do
          field :result, String, required: true
        end
      end

      it 'is expected to set the output context class' do
        expect { accept_output }
          .to change { test_class.send(:output_context_class).superclass }
          .to(output_context_class)
      end
    end

    context 'when given an invalid output context class', rbs: :skip do
      let(:output_context_class) { Class.new }

      it 'is expected to raise an ArgumentError' do
        expect { accept_output }
          .to raise_error(ArgumentError, /must be a subclass of Context::OutputContext/)
      end
    end
  end

  describe '.argument' do
    subject(:add_argument) { test_class.argument(:name, String, 'The name', required: true) }

    before { test_class.send(:input_context_class) }

    it 'is expected to delegate to the input context class' do
      allow(test_class::InputContext).to receive(:argument)
      add_argument

      expect(test_class::InputContext)
        .to have_received(:argument)
        .with(:name, String, 'The name', required: true)
    end
  end

  describe '.output' do
    subject(:add_output) { test_class.output(:result, String, 'The result', required: true) }

    before { test_class.send(:output_context_class) }

    it 'is expected to delegate to the output context class field method' do
      allow(test_class::OutputContext).to receive(:field)
      add_output

      expect(test_class::OutputContext)
        .to have_received(:field).with(:result, String, 'The result', required: true)
    end
  end
end
