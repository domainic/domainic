# frozen_string_literal: true

require 'spec_helper'
require 'domainic/attributer/errors/aggregate_error'

RSpec.describe Domainic::Attributer::AggregateError do
  describe '.new' do
    subject(:aggregate_error) { described_class.new(message, errors) }

    let(:message) { 'Multiple errors occurred:' }
    let(:errors) do
      [
        ArgumentError.new('First error'),
        TypeError.new('Second error')
      ]
    end

    it 'is expected to be a kind of Domainic::Attributer::Error' do
      expect(aggregate_error).to be_a(Domainic::Attributer::Error)
    end

    it 'is expected to store the provided errors' do
      expect(aggregate_error.errors).to eq(errors)
    end

    it 'is expected to format the error message with individual error messages' do
      expected_message = <<~MESSAGE.chomp
        Multiple errors occurred:
          - First error
          - Second error
      MESSAGE

      expect(aggregate_error.message).to eq(expected_message)
    end
  end
end
