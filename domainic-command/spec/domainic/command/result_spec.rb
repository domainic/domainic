# frozen_string_literal: true

require 'domainic/command/result'

RSpec.describe Domainic::Command::Result do
  describe '.success' do
    subject(:result) { described_class.success(context) }

    let(:context) { { value: 42 } }

    it 'is expected to create a success result' do
      expect(result).to be_successful
    end

    it 'is expected to set the status to SUCCESS' do
      expect(result.status_code).to eq(described_class::STATUS::SUCCESS)
    end

    it 'is expected to store the context' do
      expect(result.value).to eq(42)
    end

    context 'when the context contains string keys' do
      let(:context) { { 'value' => 42 } }

      it 'is expected to symbolize the keys' do
        expect(result.value).to eq(42)
      end
    end

    context 'when given an invalid context', rbs: :skip do
      let(:context) { 'not a hash' }

      it 'is expected to raise ArgumentError' do
        expect { result }.to raise_error(ArgumentError, /:context must be a Hash/)
      end
    end
  end

  describe '#and_then', rbs: :skip do
    subject(:result) { initial_result.and_then(&block) }

    let(:initial_result) { described_class.success(value: 42) }
    let(:block) { ->(r) { described_class.success(value: r.value * 2) } }

    context 'when the initial result is successful' do
      it 'is expected to execute the block and return a successful result' do
        expect(result).to be_successful
      end

      it 'is expected to return the correct transformed value' do
        expect(result.value).to eq(84)
      end
    end

    context 'when the initial result is a failure' do
      let(:initial_result) { described_class.failure({ base: 'error' }) }

      it 'is expected to return a failure result' do
        expect(result).to be_failure
      end

      it 'is expected to preserve the original error' do
        expect(result.errors[:base]).to eq(['error'])
      end
    end

    context 'when the block does not return a Result' do
      let(:block) { ->(_r) { 'not a result' } }

      it 'is expected to raise a TypeError' do
        expect { result }
          .to raise_error(TypeError, /Block must return a Domainic::Command::Result/)
      end
    end

    context 'when the block raises an exception' do
      let(:block) { ->(_r) { raise 'unexpected error' } }

      it 'is expected to propagate the exception' do
        expect { result }.to raise_error('unexpected error')
      end
    end
  end

  describe '.failure', rbs: :skip do
    subject(:result) { described_class.failure(errors, context, **options) }

    let(:errors) { { base: 'something went wrong' } }
    let(:context) { { value: 42 } }
    let(:options) { {} }

    it 'is expected to create a failure result' do
      expect(result).to be_failure
    end

    it 'is expected to set the default status to FAILED_AT_RUNTIME' do
      expect(result.status_code).to eq(described_class::STATUS::FAILED_AT_RUNTIME)
    end

    it 'is expected to store the errors' do
      expect(result.errors[:base]).to eq(['something went wrong'])
    end

    it 'is expected to store the context' do
      expect(result.value).to eq(42)
    end

    context 'when given a custom status' do
      let(:options) { { status: described_class::STATUS::FAILED_AT_INPUT } }

      it 'is expected to use the provided status' do
        expect(result.status_code).to eq(described_class::STATUS::FAILED_AT_INPUT)
      end
    end

    context 'when given an invalid status' do
      let(:options) { { status: 999 } }

      it 'is expected to raise ArgumentError' do
        expect { result }.to raise_error(ArgumentError, /invalid status code/)
      end
    end
  end

  describe '.failure_at_input' do
    subject(:result) { described_class.failure_at_input(errors, context) }

    let(:errors) { { name: 'is required' } }
    let(:context) { { value: 42 } }

    it 'is expected to create a failure result' do
      expect(result).to be_failure
    end

    it 'is expected to set the status to FAILED_AT_INPUT' do
      expect(result.status_code).to eq(described_class::STATUS::FAILED_AT_INPUT)
    end

    it 'is expected to store the errors' do
      expect(result.errors[:name]).to eq(['is required'])
    end

    it 'is expected to store the context' do
      expect(result.value).to eq(42)
    end
  end

  describe '.failure_at_output' do
    subject(:result) { described_class.failure_at_output(errors, context) }

    let(:errors) { { result: 'is invalid' } }
    let(:context) { { value: 42 } }

    it 'is expected to create a failure result' do
      expect(result).to be_failure
    end

    it 'is expected to set the status to FAILED_AT_OUTPUT' do
      expect(result.status_code).to eq(described_class::STATUS::FAILED_AT_OUTPUT)
    end

    it 'is expected to store the errors' do
      expect(result.errors[:result]).to eq(['is invalid'])
    end

    it 'is expected to store the context' do
      expect(result.value).to eq(42)
    end
  end

  describe 'result state' do
    describe '#failure?' do
      context 'when status is SUCCESS' do
        subject(:result) { described_class.success({}) }

        it { is_expected.not_to be_failure }
      end

      context 'when status is FAILED_AT_INPUT' do
        subject(:result) { described_class.failure_at_input('error') }

        it { is_expected.to be_failure }
      end

      context 'when status is FAILED_AT_RUNTIME' do
        subject(:result) { described_class.failure('error') }

        it { is_expected.to be_failure }
      end

      context 'when status is FAILED_AT_OUTPUT' do
        subject(:result) { described_class.failure_at_output('error') }

        it { is_expected.to be_failure }
      end
    end

    describe '#successful?' do
      context 'when status is SUCCESS' do
        subject(:result) { described_class.success({}) }

        it { is_expected.to be_successful }
      end

      context 'when status is FAILED_AT_INPUT' do
        subject(:result) { described_class.failure_at_input('error') }

        it { is_expected.not_to be_successful }
      end

      context 'when status is FAILED_AT_RUNTIME' do
        subject(:result) { described_class.failure('error') }

        it { is_expected.not_to be_successful }
      end

      context 'when status is FAILED_AT_OUTPUT' do
        subject(:result) { described_class.failure_at_output('error') }

        it { is_expected.not_to be_successful }
      end
    end
  end

  describe 'data access' do
    subject(:result) { described_class.success(value: 42, name: 'test') }

    describe 'method delegation' do
      it 'is expected to delegate value method to data' do
        expect(result.value).to eq(42)
      end

      it 'is expected to delegate name method to data' do
        expect(result.name).to eq('test')
      end

      it 'is expected to handle unknown methods' do
        expect { result.unknown_method }.to raise_error(NoMethodError)
      end
    end

    describe 'method reflection' do
      it 'is expected to respond to value method' do
        expect(result).to respond_to(:value)
      end

      it 'is expected to respond to name method' do
        expect(result).to respond_to(:name)
      end

      it 'is expected to not respond to unknown methods' do
        expect(result).not_to respond_to(:unknown_method)
      end
    end

    it 'is expected to have frozen data' do
      expect(result.data).to be_frozen
    end
  end
end
