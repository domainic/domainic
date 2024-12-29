# frozen_string_literal: true

require 'spec_helper'
require 'domainic/command/instance_methods'

RSpec.describe Domainic::Command::InstanceMethods do
  let(:test_class) do
    Class.new do
      include Domainic::Command::InstanceMethods

      def self.input_context_class
        @input_context_class ||= Class.new(Domainic::Command::Context::InputContext) do
          argument :name, String, required: true
        end
      end

      def self.output_context_class
        @output_context_class ||= Class.new(Domainic::Command::Context::OutputContext) do
          field :result, String, required: true
        end
      end

      def self.runtime_context_class
        @runtime_context_class ||= Class.new(Domainic::Command::Context::RuntimeContext)
      end

      def execute
        context.result = context.name.upcase
      end
    end
  end

  let(:command_instance) { test_class.new }

  describe '#call' do
    subject(:call) { command_instance.call(**context) }

    context 'when given valid input' do
      let(:context) { { name: 'test' } }

      it 'is expected to return a successful result' do
        expect(call).to be_successful
      end

      it 'is expected to process the input' do
        expect(call.result).to eq('TEST')
      end
    end

    context 'when given invalid input' do
      let(:context) { {} }

      it 'is expected to return a failed result' do
        expect(call).to be_failure
      end

      it 'is expected to have input validation errors' do
        expect(call.status_code).to eq(Domainic::Command::Result::STATUS::FAILED_AT_INPUT)
      end
    end
  end

  describe '#call!' do
    subject(:call!) { command_instance.call!(**context) }

    context 'when given valid input' do
      let(:context) { { name: 'test' } }

      it 'is expected to return a successful result' do
        expect(call!).to be_successful
      end
    end

    context 'when given invalid input' do
      let(:context) { {} }

      it 'is expected to raise an ExecutionError' do
        expect { call! }
          .to raise_error(Domainic::Command::ExecutionError)
          .with_message(/has invalid input/)
      end
    end

    context 'when execution fails', rbs: :skip do
      let(:context) { { name: 'test' } }
      let(:runtime_error) { RuntimeError.new('Execution failed') }

      before do
        allow(command_instance).to receive(:execute).and_raise(runtime_error)
      end

      it 'is expected to raise an ExecutionError' do
        expect { call! }
          .to raise_error(Domainic::Command::ExecutionError)
          .with_message(/failed/)
      end

      it 'is expected to include the original error in the result' do
        call!
      rescue Domainic::Command::ExecutionError => e
        expect(e.result.errors[:generic]).to include(runtime_error.message)
      end
    end
  end
end
