# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/specification/duck_type'

RSpec.describe Domainic::Type::DuckType do
  describe '#validate' do
    subject(:validate) { type.validate(test_object) }

    let(:type) { described_class.new }
    let(:test_object) do
      Struct.new(:foo, :bar) do
        def baz; end
      end.new('foo', 'bar')
    end

    context 'when checking method presence' do
      before { type.responding_to(:foo, :baz) }

      context 'when all required methods are present' do
        it { is_expected.to be true }
      end

      context 'when a required method is missing' do
        before { type.responding_to(:missing) }

        it { is_expected.to be false }
      end
    end

    context 'when checking method exclusion' do
      before { type.not_responding_to(:qux, :quux) }

      context 'when no excluded methods are present' do
        it { is_expected.to be true }
      end

      context 'when an excluded method is present' do
        before { type.not_responding_to(:foo) }

        it { is_expected.to be false }
      end
    end

    context 'when combining presence and exclusion' do
      before do
        type.responding_to(:foo, :baz)
            .not_responding_to(:qux)
      end

      it { is_expected.to be true }

      context 'when adding an excluded method that exists' do
        before { type.not_responding_to(:bar) }

        it { is_expected.to be false }
      end

      context 'when adding a required method that is missing' do
        before { type.responding_to(:missing) }

        it { is_expected.to be false }
      end
    end
  end
end
