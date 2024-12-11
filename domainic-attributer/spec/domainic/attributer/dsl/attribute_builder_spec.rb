# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::DSL::AttributeBuilder do
  subject(:builder) { described_class.new(base, :test, :argument, type_validator) }

  let(:base) { Class.new }
  let(:type_validator) { Domainic::Attributer::Undefined }

  describe '#build!' do
    it 'is expected to build an Attribute instance' do
      expect(builder.build!).to be_an_instance_of(Domainic::Attributer::Attribute)
    end

    it 'is expected to set the name' do
      expect(builder.build!.instance_variable_get(:@name)).to eq(:test)
    end

    it 'is expected to set the base' do
      expect(builder.build!.instance_variable_get(:@base)).to eq(base)
    end
  end

  describe '#coerce_with' do
    context 'with proc' do
      it 'is expected to add the coercer' do
        coercer = ->(value) { "#{value}_test" }
        builder.coerce_with(coercer)
        expect(builder.instance_variable_get(:@options)[:coercers]).to include(coercer)
      end
    end

    context 'with block' do
      it 'is expected to add the block as coercer' do
        builder.coerce_with(&:to_s)
        expect(builder.instance_variable_get(:@options)[:coercers].first).to be_a(Proc)
      end
    end
  end

  describe '#default' do
    context 'with value' do
      it 'is expected to set the default value' do
        builder.default('test')
        expect(builder.instance_variable_get(:@options)[:default]).to eq('test')
      end
    end

    context 'with block' do
      it 'is expected to set the default generator', rbs: :skip do
        generator = proc { 'test' }
        builder.default(&generator)
        expect(builder.instance_variable_get(:@options)[:default]).to eq(generator)
      end
    end
  end

  describe '#description' do
    it 'is expected to set the description' do
      builder.description('test description')
      expect(builder.instance_variable_get(:@options)[:description]).to eq('test description')
    end
  end

  describe '#on_change' do
    context 'with proc' do
      it 'is expected to add the callback' do
        callback = ->(old_value, new_value) { [old_value, new_value] }
        builder.on_change(callback)
        expect(builder.instance_variable_get(:@options)[:callbacks]).to include(callback)
      end
    end

    context 'with block' do
      it 'is expected to add the block as callback' do
        builder.on_change { |old_value, new_value| [old_value, new_value] }
        expect(builder.instance_variable_get(:@options)[:callbacks].first).to be_a(Proc)
      end
    end
  end

  shared_examples 'visibility modifier' do |method, access_type|
    it 'is expected to set read visibility' do
      builder.public_send(method)
      expect(builder.instance_variable_get(:@options)[:read]).to eq(access_type)
    end

    it 'is expected to set write visibility' do
      builder.public_send(method)
      expect(builder.instance_variable_get(:@options)[:write]).to eq(access_type)
    end
  end

  describe '#private' do
    include_examples 'visibility modifier', :private, :private
  end

  describe '#protected' do
    include_examples 'visibility modifier', :protected, :protected
  end

  describe '#public' do
    include_examples 'visibility modifier', :public, :public
  end

  shared_examples 'single visibility modifier' do |method, access_type, option|
    it "is expected to set #{option} visibility to #{access_type}" do
      builder.public_send(method)
      expect(builder.instance_variable_get(:@options)[option]).to eq(access_type)
    end
  end

  describe '#private_read' do
    include_examples 'single visibility modifier', :private_read, :private, :read
  end

  describe '#private_write' do
    include_examples 'single visibility modifier', :private_write, :private, :write
  end

  describe '#protected_read' do
    include_examples 'single visibility modifier', :protected_read, :protected, :read
  end

  describe '#protected_write' do
    include_examples 'single visibility modifier', :protected_write, :protected, :write
  end

  describe '#public_read' do
    include_examples 'single visibility modifier', :public_read, :public, :read
  end

  describe '#public_write' do
    include_examples 'single visibility modifier', :public_write, :public, :write
  end

  describe '#non_nilable' do
    it 'is expected to set the nilable flag' do
      builder.non_nilable
      expect(builder.instance_variable_get(:@options)[:nilable]).to be false
    end
  end

  describe '#required' do
    it 'is expected to set the required flag' do
      builder.required
      expect(builder.instance_variable_get(:@options)[:required]).to be true
    end
  end

  describe '#validate_with' do
    context 'with proc' do
      it 'is expected to add the validator' do
        validator = ->(value) { value.is_a?(String) }
        builder.validate_with(validator)
        expect(builder.instance_variable_get(:@options)[:validators]).to include(validator)
      end
    end

    context 'with block' do
      it 'is expected to add the block as validator' do
        builder.validate_with { |value| value.is_a?(String) }
        expect(builder.instance_variable_get(:@options)[:validators].first).to be_a(Proc)
      end
    end
  end

  context 'when given a type validator' do
    let(:type_validator) { ->(value) { value.is_a?(String) } }

    it 'is expected to add the validator' do
      expect(builder.instance_variable_get(:@options)[:validators]).to include(type_validator)
    end
  end

  context 'with configuration block' do
    subject(:builder) { described_class.new(base, :test, :argument, type_validator) { required } }

    it 'is expected to execute the configuration' do
      expect(builder.instance_variable_get(:@options)[:required]).to be true
    end
  end
end
