# frozen_string_literal: true

require 'spec_helper'
require 'domainic/command/result/status'

RSpec.describe Domainic::Command::Result::STATUS do
  describe 'status codes' do
    it 'is expected to define SUCCESS as 0' do
      expect(described_class::SUCCESS).to eq(0)
    end

    it 'is expected to define FAILED_AT_RUNTIME as 1' do
      expect(described_class::FAILED_AT_RUNTIME).to eq(1)
    end

    it 'is expected to define FAILED_AT_INPUT as 2' do
      expect(described_class::FAILED_AT_INPUT).to eq(2)
    end

    it 'is expected to define FAILED_AT_OUTPUT as 3' do
      expect(described_class::FAILED_AT_OUTPUT).to eq(3)
    end
  end
end
