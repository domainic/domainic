# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::Attribute::Validator do
  let(:attribute) { instance_double(Domainic::Attributer::Attribute, base: test_class, name: :test) }
  let(:test_class) { Class.new }

  before do
    allow(attribute).to receive(:is_a?).with(Domainic::Attributer::Attribute).and_return(true)
  end

  describe '.new' do
    subject(:validator) { described_class.new(attribute, handlers) }

    context 'with a Proc handler' do
      let(:handlers) { ->(value) { value.is_a?(String) } }

      it { expect { validator }.not_to raise_error }
    end

    context 'with a class handler' do
      let(:handlers) { String }

      it { expect { validator }.not_to raise_error }
    end

    context 'with an object handler' do
      let(:handlers) { test_class.new }

      it { expect { validator }.not_to raise_error }
    end

    context 'with multiple handlers' do
      let(:handlers) { [proc { |value| value.is_a?(String) }, String] }

      it { expect { validator }.not_to raise_error }
    end
  end

  describe '#call' do
    subject(:call) { validator.call(test_class.new, value) }

    let(:validator) { described_class.new(attribute, handlers) }

    context 'with a valid value' do
      let(:handlers) { ->(v) { v.is_a?(String) } }
      let(:value) { 'hello' }

      it 'is expected to not raise an error' do
        expect { call }.not_to raise_error
      end
    end

    context 'with an invalid value' do
      let(:handlers) { ->(v) { v.is_a?(String) } }
      let(:value) { 42 }

      it 'is expected to raise an ArgumentError' do
        expect { call }.to raise_error(ArgumentError, /has invalid value: 42/)
      end
    end

    context 'with an Undefined value' do
      let(:handlers) { [] }
      let(:value) { Domainic::Attributer::Undefined }

      context 'when the attribute is not required' do
        before do
          signature = instance_double(Domainic::Attributer::Attribute::Signature, optional?: true, required?: false)
          allow(attribute).to receive(:signature).and_return(signature)
        end

        it 'is expected to not raise an error' do
          expect { call }.not_to raise_error
        end
      end

      context 'when the attribute is required' do
        before do
          signature = instance_double(Domainic::Attributer::Attribute::Signature, optional?: false, required?: true)
          allow(attribute).to receive(:signature).and_return(signature)
        end

        it { expect { call }.to raise_error(ArgumentError, /is required/) }
      end
    end

    context 'with a nil value' do
      let(:handlers) { [] }
      let(:value) { nil }

      context 'when the attribute is nilable' do
        before do
          signature = instance_double(Domainic::Attributer::Attribute::Signature, nilable?: true)
          allow(attribute).to receive(:signature).and_return(signature)
        end

        it 'is expected to not raise an error' do
          expect { call }.not_to raise_error
        end
      end

      context 'when the attribute is not nilable' do
        before do
          signature = instance_double(Domainic::Attributer::Attribute::Signature, nilable?: false)
          allow(attribute).to receive(:signature).and_return(signature)
        end

        it { expect { call }.to raise_error(ArgumentError, /cannot be nil/) }
      end
    end

    context 'with a class handler' do
      let(:handlers) { String }
      let(:value) { 'hello' }

      it 'is expected to not raise an error' do
        expect { call }.not_to raise_error
      end
    end

    context 'with multiple handlers' do
      let(:handlers) { [proc { |v| v.is_a?(String) }, String] }
      let(:value) { 'hello' }

      it 'is expected to not raise an error' do
        expect { call }.not_to raise_error
      end
    end

    context 'when a handler raises an error' do
      let(:handlers) do
        [
          ->(*) { raise 'First error' },
          ->(*) { raise 'Second error' }
        ]
      end
      let(:value) { 'hello' }

      let(:expected_message) do
        <<~MESSAGE.chomp
          The following errors occurred during validation execution:
            - First error
            - Second error
        MESSAGE
      end

      it { expect { call }.to raise_error(Domainic::Attributer::ValidationExecutionError) }

      it 'is expected to include all error messages' do
        expect { call }.to raise_error(expected_message)
      end
    end
  end
end
