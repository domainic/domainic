# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/specification/void_type'

RSpec.describe Domainic::Type::VoidType do
  describe '#validate' do
    subject(:validate) { type.validate(value) }

    let(:type) { described_class.new }
    let(:value) { [123, 1.2, 'abc', nil, true, false, Object.new, [], {}, :symbol].sample }

    it { is_expected.to be true }
  end
end
