# frozen_string_literal: true

require 'rspec'
require 'domainic/command/context/behavior'

RSpec.describe Domainic::Command::Context::Behavior do
  let(:context_class) do
    Class.new do
      include Domainic::Command::Context::Behavior

      attribute :name, String
    end
  end

  describe '.new' do
    subject(:new_context) { context_class.new(**attributes) }

    context 'when given valid attributes' do
      let(:attributes) { { name: 'Test' } }

      it { is_expected.to have_attributes(name: 'Test') }
    end

    context 'when a value is invalid' do
      let(:attributes) { { name: 123 } }

      it 'is expected to raise ArgumentError' do
        expect { new_context }.to raise_error(ArgumentError, /Invalid value for name/)
      end
    end
  end

  describe '.inherited' do
    subject(:inheritance) { Class.new(context_class) }

    it 'is expected to inherit attributes from the parent class' do
      expect(inheritance.send(:attributes).all.map(&:name)).to contain_exactly(:name)
    end

    it 'is expected to create a new copy of the attributes' do
      expect(inheritance.send(:attributes)).not_to equal(context_class.send(:attributes))
    end

    context 'when adding attributes to the child class' do
      before do
        inheritance.send(:attribute, :email, String)
      end

      it 'is expected not to affect the parent class attributes' do
        expect(context_class.send(:attributes).all.map(&:name)).not_to include(:email)
      end
    end
  end

  describe '.attribute' do
    let(:add_attribute) { -> { context_class.send(:attribute, :test, String) } }
    let(:new_instance) { -> { context_class.new(name: 'Test', test: 'value') } }

    it 'is expected to create an attr_reader' do
      add_attribute.call
      expect(new_instance.call).to respond_to(:test)
    end

    context 'when multithreaded attribute definition occurs' do
      let(:threads) do
        Array.new(5) do |i|
          Thread.new do
            context_class.send(:attribute, :"concurrent_attr#{i}", String)
          end
        end
      end

      it 'is expected to safely add the first concurrent attribute' do
        threads.each(&:join)
        expect(context_class.send(:attributes).all.map(&:name)).to include(:concurrent_attr0)
      end

      it 'is expected to safely add the last concurrent attribute' do
        threads.each(&:join)
        expect(context_class.send(:attributes).all.map(&:name)).to include(:concurrent_attr4)
      end
    end
  end

  describe '#to_hash' do
    subject(:to_hash) { instance.to_hash }

    let(:instance) { context_class.new(name: 'Test') }

    it { is_expected.to eq(name: 'Test') }

    context 'when a subclass overrides an attribute reader' do
      let(:context_class) do
        Class.new do
          include Domainic::Command::Context::Behavior

          attribute :name, String

          def name
            "#{@name} (modified)"
          end
        end
      end

      let(:instance) { context_class.new(name: 'Test') }

      it 'is expected to use the overridden value' do
        expect(to_hash[:name]).to eq('Test (modified)')
      end
    end
  end

  describe '#to_h' do
    subject(:to_h) { instance.to_h }

    let(:instance) { context_class.new(name: 'Test') }

    it { is_expected.to eq(name: 'Test') }
  end
end
