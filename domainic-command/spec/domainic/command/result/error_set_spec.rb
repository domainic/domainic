# frozen_string_literal: true

require 'spec_helper'
require 'domainic/command/result/error_set'

RSpec.describe Domainic::Command::Result::ErrorSet do
  describe '.new' do
    subject(:error_set) { described_class.new(errors) }

    context 'when given nil' do
      let(:errors) { nil }

      it 'is expected to create an empty error set' do
        expect(error_set.messages).to be_empty
      end
    end

    context 'when given a string' do
      let(:errors) { 'something went wrong' }

      it 'is expected to parse as a generic error' do
        expect(error_set[:generic]).to eq(['something went wrong'])
      end
    end

    context 'when given an array' do
      let(:errors) { ['error 1', 'error 2'] }

      it 'is expected to parse as generic errors' do
        expect(error_set[:generic]).to eq(['error 1', 'error 2'])
      end

      context 'when array contains standard errors' do
        let(:errors) { ['error 1', StandardError.new('error 2')] }

        it 'is expected to parse error messages' do
          expect(error_set[:generic]).to eq(['error 1', 'error 2'])
        end
      end

      context 'when array contains invalid values', rbs: :skip do
        let(:errors) { ['error 1', 123] }

        it 'is expected to raise ArgumentError' do
          expect { error_set }.to raise_error(ArgumentError, /invalid errors/)
        end
      end
    end

    context 'when given a hash' do
      let(:errors) { { name: 'invalid', email: ['invalid format', 'taken'] } }

      it 'is expected to parse name errors' do
        expect(error_set[:name]).to eq(['invalid'])
      end

      it 'is expected to parse email errors' do
        expect(error_set[:email]).to eq(['invalid format', 'taken'])
      end

      context 'when hash contains standard errors' do
        let(:errors) { { name: StandardError.new('invalid') } }

        it 'is expected to parse error messages' do
          expect(error_set[:name]).to eq(['invalid'])
        end
      end

      context 'when hash contains arrays with standard errors' do
        let(:errors) do
          {
            email: [
              StandardError.new('invalid format'),
              StandardError.new('taken')
            ]
          }
        end

        it 'is expected to parse error messages' do
          expect(error_set[:email]).to eq(['invalid format', 'taken'])
        end
      end

      context 'when hash contains invalid values', rbs: :skip do
        let(:errors) { { name: 123 } }

        it 'is expected to raise ArgumentError' do
          expect { error_set }.to raise_error(ArgumentError, /invalid errors/)
        end
      end
    end

    context 'when given a StandardError' do
      let(:errors) { StandardError.new('something went wrong') }

      it 'is expected to parse as a generic error' do
        expect(error_set[:generic]).to eq(['something went wrong'])
      end
    end

    context 'when given an object responding to to_h' do
      let(:errors) do
        Class.new do
          def to_h
            { name: 'invalid', email: ['invalid format', 'taken'] }
          end
        end.new
      end

      it 'is expected to parse name errors' do
        expect(error_set[:name]).to eq(['invalid'])
      end

      it 'is expected to parse email errors' do
        expect(error_set[:email]).to eq(['invalid format', 'taken'])
      end
    end
  end

  describe '#[]' do
    subject(:error_messages) { error_set[key] }

    let(:error_set) { described_class.new(name: 'invalid') }

    context 'when given a symbol key' do
      let(:key) { :name }

      it 'is expected to return messages for that key' do
        expect(error_messages).to eq(['invalid'])
      end
    end

    context 'when given a string key' do
      let(:key) { 'name' }

      it 'is expected to return messages for that key' do
        expect(error_messages).to eq(['invalid'])
      end
    end

    context 'when given a non-existent key' do
      let(:key) { :missing }

      it 'is expected to return nil' do
        expect(error_messages).to be_nil
      end
    end
  end

  describe '#add' do
    subject(:add_error) { error_set.add(key, message) }

    let(:error_set) { described_class.new }
    let(:key) { :name }

    context 'when adding a string message' do
      let(:message) { 'invalid' }

      it 'is expected to add the message to the key' do
        expect { add_error }
          .to change { error_set[key] }
          .from(nil)
          .to(['invalid'])
      end
    end

    context 'when adding an array of messages' do
      let(:message) { ['invalid format', 'taken'] }

      it 'is expected to add all messages to the key' do
        expect { add_error }
          .to change { error_set[key] }
          .from(nil)
          .to(['invalid format', 'taken'])
      end
    end

    context 'when adding to existing messages' do
      let(:error_set) { described_class.new(name: 'invalid') }
      let(:message) { 'taken' }

      it 'is expected to append the message' do
        expect { add_error }
          .to change { error_set[key] }
          .from(['invalid'])
          .to(%w[invalid taken])
      end
    end
  end

  describe '#full_messages' do
    subject(:full_messages) { error_set.full_messages }

    let(:error_set) { described_class.new(errors) }
    let(:errors) do
      {
        name: 'invalid',
        email: ['invalid format', 'taken']
      }
    end

    it 'is expected to return all messages with their keys' do
      expect(full_messages).to contain_exactly('name invalid', 'email invalid format', 'email taken')
    end
  end

  describe '#messages' do
    subject(:messages) { error_set.messages }

    let(:error_set) { described_class.new(name: 'invalid') }

    it 'is expected to return a frozen hash' do
      expect(messages).to be_frozen
    end

    it 'is expected to contain the correct messages' do
      expect(messages).to eq(name: ['invalid'])
    end

    it 'is expected to return a new hash instance' do
      expect(messages).not_to be(error_set.messages)
    end
  end
end
