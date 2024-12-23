# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/core/symbol_type'

RSpec.describe Domainic::Type::SymbolType do
  subject(:type) { described_class.new }

  describe '.validate' do
    context 'when validating a symbol' do
      subject(:validation) { described_class.validate(:test_symbol) }

      it { is_expected.to be true }
    end

    context 'when validating a non-symbol' do
      subject(:validation) { described_class.validate('not_a_symbol') }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    context 'when validating a symbol' do
      subject(:validation) { described_class.validate!(:test_symbol) }

      it { is_expected.to be true }
    end

    context 'when validating a non-symbol' do
      it 'is expected to raise TypeError' do
        expect { described_class.validate!('not_a_symbol') }
          .to raise_error(TypeError, /Expected Symbol, but got String/)
      end
    end
  end

  describe 'string behavior' do
    describe '#being_alphanumeric' do
      context 'when validating an alphanumeric symbol' do
        subject(:validation) { type.being_alphanumeric.validate(:abc123) }

        it { is_expected.to be true }
      end

      context 'when validating a non-alphanumeric symbol' do
        subject(:validation) { type.being_alphanumeric.validate(:'abc-123') }

        it { is_expected.to be false }
      end
    end

    describe '#being_lowercase' do
      context 'when validating a lowercase symbol' do
        subject(:validation) { type.being_lowercase.validate(:hello) }

        it { is_expected.to be true }
      end

      context 'when validating a non-lowercase symbol' do
        subject(:validation) { type.being_lowercase.validate(:Hello) }

        it { is_expected.to be false }
      end
    end

    describe '#having_size' do
      context 'when validating a symbol of correct length' do
        subject(:validation) { type.having_size(5).validate(:hello) }

        it { is_expected.to be true }
      end

      context 'when validating a symbol of incorrect length' do
        subject(:validation) { type.having_size(3).validate(:hello) }

        it { is_expected.to be false }
      end
    end

    describe '#matching' do
      context 'when validating a symbol matching the pattern' do
        subject(:validation) { type.matching(/^[a-z]+$/).validate(:hello) }

        it { is_expected.to be true }
      end

      context 'when validating a symbol not matching the pattern' do
        subject(:validation) { type.matching(/^[a-z]+$/).validate(:hello123) }

        it { is_expected.to be false }
      end
    end
  end
end
