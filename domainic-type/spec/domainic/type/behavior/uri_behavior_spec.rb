# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/behavior'
require 'domainic/type/behavior/uri_behavior'

RSpec.describe Domainic::Type::Behavior::URIBehavior do
  subject(:type) { test_class.new }

  let(:test_class) do
    Class.new do
      include Domainic::Type::Behavior
      include Domainic::Type::Behavior::URIBehavior

      intrinsically_constrain :self, :type, String, abort_on_failure: true, description: :not_described
    end
  end

  describe '#having_top_level_domain' do
    context 'when validating a URI with an allowed TLD' do
      subject(:validation) { type.having_top_level_domain('com', 'org').validate('example.com') }

      it { is_expected.to be true }
    end

    context 'when validating a URI without an allowed TLD' do
      subject(:validation) { type.having_top_level_domain('com', 'org').validate('example.net') }

      it { is_expected.to be false }
    end
  end

  describe '#not_having_top_level_domain' do
    context 'when validating a URI without a forbidden TLD' do
      subject(:validation) { type.not_having_top_level_domain('test', 'dev').validate('example.com') }

      it { is_expected.to be true }
    end

    context 'when validating a URI with a forbidden TLD' do
      subject(:validation) { type.not_having_top_level_domain('test', 'dev').validate('example.dev') }

      it { is_expected.to be false }
    end
  end

  describe 'aliases for #having_top_level_domain' do
    subject(:validation) { type.tld('com', 'org').validate('example.com') }

    it 'is expected to behave like #having_top_level_domain' do
      expect(validation).to be true
    end
  end

  describe 'aliases for #not_having_top_level_domain' do
    subject(:validation) { type.not_tld('test').validate('example.com') }

    it 'is expected to behave like #not_having_top_level_domain' do
      expect(validation).to be true
    end
  end
end
