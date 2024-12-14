# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::Attribute::Callback do
  let(:attribute) { instance_double(Domainic::Attributer::Attribute, base: Class.new, name: :test) }
  let(:handlers) { [] }

  describe '.new' do
    subject(:callback) { described_class.new(attribute, handlers) }

    context 'when given valid handlers' do
      let(:handlers) { [valid_handler] }
      let(:valid_handler) { ->(old_value, new_value) { [old_value, new_value] } }

      it { expect { callback }.not_to raise_error }
    end

    context 'when given invalid handler', rbs: :skip do
      let(:handlers) { ['not_a_proc'] }

      it {
        expect { callback }.to raise_error(
          TypeError,
          /invalid handler: "not_a_proc"\. Must be a Proc/
        )
      }
    end

    context 'when handlers contain duplicates' do
      let(:valid_handler) { ->(old_value, new_value) { [old_value, new_value] } }
      let(:handlers) { [valid_handler, valid_handler] }

      it 'is expected to remove duplicates' do
        expect(callback.instance_variable_get(:@handlers).length).to eq(1)
      end
    end
  end

  describe '#call' do
    subject(:call) { callback.call(instance, old_value, new_value) }

    let(:callback) { described_class.new(attribute, handlers) }
    let(:instance) { Class.new.new }
    let(:new_value) { 'new_test' }
    let(:old_value) { 'old_test' }

    context 'without handlers' do
      let(:handler) { [] }

      it 'is expected not to raise error' do
        expect { call }.not_to raise_error
      end
    end

    context 'with single handler' do
      let(:received) { [] }
      let(:instance) do
        test_values = received
        Class.new do
          define_method(:capture_values) do |old, new|
            test_values << [old, new]
          end
        end.new
      end
      let(:handlers) { [->(old, new) { capture_values(old, new) }] }

      it 'is expected to call the handler' do
        call
        expect(received).to contain_exactly([old_value, new_value])
      end
    end

    context 'with multiple handlers' do
      let(:received) { [] }
      let(:instance) do
        test_values = received
        Class.new do
          define_method(:capture_values) do |old, new, position|
            test_values << [position, old, new]
          end
        end.new
      end
      let(:handlers) do
        [
          ->(old, new) { capture_values(old, new, :first) },
          ->(old, new) { capture_values(old, new, :second) }
        ]
      end

      it 'is expected to call handlers in order' do
        call
        expect(received).to eq([[:first, old_value, new_value], [:second, old_value, new_value]])
      end
    end

    context 'with instance state access' do
      let(:instance) do
        Class.new do
          def initialize
            @values = []
          end

          def record_values(old, new)
            @values << [old, new]
          end

          def recorded_values
            @values
          end
        end.new
      end

      let(:handlers) { [->(old, new) { record_values(old, new) }] }

      it 'is expected to execute handlers in instance context' do
        call
        expect(instance.recorded_values).to contain_exactly([old_value, new_value])
      end
    end

    context 'when a handler raises an error' do
      let(:handlers) do
        [
          ->(*) { raise 'First error' },
          ->(*) { raise 'Second error' }
        ]
      end

      let(:expected_message) do
        <<~MESSAGE.chomp
          The following errors occurred during callback execution:
            - First error
            - Second error
        MESSAGE
      end

      it { expect { call }.to raise_error(Domainic::Attributer::CallbackExecutionError) }

      it 'is expected to include all error messages' do
        expect { call }.to raise_error(expected_message)
      end
    end
  end
end
