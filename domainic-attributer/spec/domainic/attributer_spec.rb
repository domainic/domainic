# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer do
  describe '.Attributer' do
    subject(:custom_attributer) { Domainic.Attributer(**options) }

    let(:options) { { argument: :param, option: :opt } }

    it { is_expected.to be_a(Module) }

    context 'when included in a class' do
      let(:dummy_class) do
        Class.new do
          include Domainic.Attributer(argument: :param, option: :opt)
        end
      end

      it 'is expected to define custom method names' do
        aggregate_failures do
          expect(dummy_class).to respond_to(:param)
          expect(dummy_class).to respond_to(:opt)
        end
      end

      it 'is expected to have the expected attribute methods' do
        dummy_class.param :test
        attribute = dummy_class.send(:__attributes__)[:test]
        expect(attribute.signature.type).to eq(:argument)
      end
    end
  end
end
