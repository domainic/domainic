# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/boolean_type'

RSpec.describe Domainic::Type::BooleanType do
  describe '#validate' do
    subject(:validate) { described_class.new.validate(subject_value) }

    context 'when the value is true' do
      let(:subject_value) { true }

      it { is_expected.to be true }
    end

    context 'when the value is false' do
      let(:subject_value) { false }

      it { is_expected.to be true }
    end

    context 'when the value is not a boolean' do
      let(:subject_value) { 1 }

      it { is_expected.to be false }
    end
  end
end
