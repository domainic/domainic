# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::Undefined do
  describe '.clone' do
    subject(:clone) { described_class.clone }

    it { is_expected.to be described_class }
  end

  describe '.dup' do
    subject(:dup) { described_class.dup }

    it { is_expected.to be described_class }
  end

  describe '.inspect' do
    subject(:inspect) { described_class.inspect }

    it { is_expected.to eq 'Undefined' }
  end

  describe '.to_s' do
    subject(:to_string) { described_class.to_s }

    it { is_expected.to eq 'Undefined' }
  end
end
