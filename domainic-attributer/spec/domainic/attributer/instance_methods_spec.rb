# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Domainic::Attributer::InstanceMethods do
  let(:dummy_class) do
    Class.new do
      extend Domainic::Attributer::ClassMethods
      include Domainic::Attributer::InstanceMethods

      argument :foo
      option :bar
      option :baz, read: :private
    end
  end

  let(:instance) { dummy_class.new('foo_value', bar: 'bar_value', baz: 'baz_value') }

  describe '#to_hash' do
    subject(:to_hash) { instance.to_hash }

    it 'is expected to include only public readable attributes' do
      expect(to_hash).to eq(foo: 'foo_value', bar: 'bar_value')
    end
  end
end
