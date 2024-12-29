# frozen_string_literal: true

require 'spec_helper'
require 'date'

RSpec.describe Domainic::Command do
  describe '.included' do
    subject(:include_command) { test_class.include(described_class) }

    let(:test_class) { Class.new }

    it 'is expected to extend the class with ClassMethods' do
      expect { include_command }.to change { test_class.singleton_class.included_modules }
        .to include(described_class::ClassMethods)
    end

    it 'is expected to include InstanceMethods' do
      expect { include_command }.to change(test_class, :included_modules)
        .to include(described_class::InstanceMethods)
    end
  end

  describe 'command integration' do
    subject(:command_instance) { command_class.new }

    let(:command_class) do
      Class.new do
        include Domainic::Command

        argument :name, String, 'The name', required: true
        argument :age, Integer, 'The age', default: 0

        output :formatted_name, String, 'The formatted name', required: true
        output :birth_year, Integer, 'The calculated birth year'

        def execute
          context.formatted_name = context.name.upcase
          context.birth_year = Date.today.year - context.age
        end
      end
    end

    describe '.call' do
      subject(:call) { command_class.call(**context) }

      context 'when given valid arguments' do
        let(:context) { { name: 'John', age: 30 } }
        let(:current_year) { Date.today.year }

        it 'is expected to return a successful result' do
          expect(call).to be_successful
        end

        it 'is expected to set the formatted name' do
          expect(call.formatted_name).to eq('JOHN')
        end

        it 'is expected to calculate the birth year' do
          expect(call.birth_year).to eq(current_year - 30)
        end
      end

      context 'when given invalid arguments' do
        let(:context) { { age: 30 } }

        it 'is expected to return a failed result' do
          expect(call).to be_failure
        end

        it 'is expected to have an input validation error' do
          expect(call.status_code).to eq(Domainic::Command::Result::STATUS::FAILED_AT_INPUT)
        end
      end
    end

    describe '.call!' do
      subject(:call!) { command_class.call!(**context) }

      context 'when given valid arguments' do
        let(:context) { { name: 'John', age: 30 } }

        it 'is expected to return a successful result' do
          expect(call!).to be_successful
        end
      end

      context 'when given invalid arguments' do
        let(:context) { { age: 30 } }

        it 'is expected to raise an ExecutionError' do
          expect { call! }.to raise_error(Domainic::Command::ExecutionError)
        end
      end
    end

    describe '#execute' do
      subject(:execute) { command_instance.execute }

      let(:unimplemented_command) do
        Class.new do
          include Domainic::Command
        end
      end

      it 'is expected to raise NotImplementedError when not implemented' do
        expect { unimplemented_command.new.execute }
          .to raise_error(NotImplementedError, /does not implement #execute/)
      end
    end
  end
end
