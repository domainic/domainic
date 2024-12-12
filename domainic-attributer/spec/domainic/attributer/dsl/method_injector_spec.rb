# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::DSL::MethodInjector do
  let(:base) { Class.new }
  let(:signature) { instance_double(Domainic::Attributer::Attribute::Signature) }
  let(:attribute) { instance_double(Domainic::Attributer::Attribute, signature: signature) }

  before do
    allow(attribute).to receive_messages(name: :test, signature: signature)
    allow(signature).to receive_messages(read_visibility: :public, write_visibility: :public)
  end

  describe '.inject!' do
    subject(:inject) { described_class.inject!(base, attribute) }

    it 'is expected to create a reader method' do
      inject
      expect(base.method_defined?(:test)).to be true
    end

    it 'is expected to create a writer method' do
      inject
      expect(base.method_defined?(:test=)).to be true
    end

    context 'with private read visibility' do
      before do
        allow(signature).to receive(:read_visibility).and_return(:private)
      end

      it 'is expected to create a private reader' do
        inject
        expect(base.private_method_defined?(:test)).to be true
      end
    end

    context 'with protected read visibility' do
      before do
        allow(signature).to receive(:read_visibility).and_return(:protected)
      end

      it 'is expected to create a protected reader' do
        inject
        expect(base.protected_method_defined?(:test)).to be true
      end
    end

    context 'with private write visibility' do
      before do
        allow(signature).to receive(:write_visibility).and_return(:private)
      end

      it 'is expected to create a private writer' do
        inject
        expect(base.private_method_defined?(:test=)).to be true
      end
    end

    context 'with protected write visibility' do
      before do
        allow(signature).to receive(:write_visibility).and_return(:protected)
      end

      it 'is expected to create a protected writer' do
        inject
        expect(base.protected_method_defined?(:test=)).to be true
      end
    end

    context 'when writer method exists' do
      before do
        base.define_method(:test=) { |_value| 'existing' }
      end

      it 'is expected not to override the existing writer' do
        expect { inject }.not_to(change do
          base.instance_method(:test=).owner
        end)
      end
    end

    context 'with attribute system integration' do
      let(:instance) { base.new }
      let(:attributes) { { test: attribute } }

      before do
        allow(base).to receive(:__attributes__).and_return(attributes)
        allow(attribute).to receive(:apply!)
        inject
      end

      it 'is expected to process values through the attribute system' do
        instance.test = 'value'
        expect(attribute).to have_received(:apply!).with(instance, 'value')
      end
    end
  end
end
