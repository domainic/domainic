# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/behavior'
require 'domainic/type/behavior/string_behavior/matching_behavior'

RSpec.describe Domainic::Type::Behavior::StringBehavior::MatchingBehavior do
  subject(:type) { test_class.new }

  let(:test_class) do
    Class.new do
      include Domainic::Type::Behavior
      include Domainic::Type::Behavior::StringBehavior::MatchingBehavior

      intrinsically_constrain :self, :type, String, abort_on_failure: true, description: :not_described
    end
  end

  describe '#being_equal_to' do
    context 'when validating a matching string' do
      subject(:validation) { type.being_equal_to('hello').validate('hello') }

      it { is_expected.to be true }
    end

    context 'when validating a non-matching string' do
      subject(:validation) { type.being_equal_to('hello').validate('world') }

      it { is_expected.to be false }
    end
  end

  describe '#containing' do
    context 'when validating a string containing all specified substrings' do
      subject(:validation) { type.containing('hello', 'world').validate('hello world') }

      it { is_expected.to be true }
    end

    context 'when validating a string missing specified substrings' do
      subject(:validation) { type.containing('hello', 'there').validate('hello world') }

      it { is_expected.to be false }
    end
  end

  describe '#excluding' do
    context 'when validating a string without specified substrings' do
      subject(:validation) { type.excluding('foo', 'bar').validate('hello world') }

      it { is_expected.to be true }
    end

    context 'when validating a string with specified substrings' do
      subject(:validation) { type.excluding('hello', 'world').validate('hello world') }

      it { is_expected.to be false }
    end
  end

  describe '#matching' do
    context 'when validating a string matching all patterns' do
      subject(:validation) { type.matching(/^\w+$/, /\d/).validate('hello123') }

      it { is_expected.to be true }
    end

    context 'when validating a string not matching all patterns' do
      subject(:validation) { type.matching(/^\w+$/, /\d/).validate('hello') }

      it { is_expected.to be false }
    end
  end

  describe '#not_being_equal_to' do
    context 'when validating a non-matching string' do
      subject(:validation) { type.not_being_equal_to('world').validate('hello') }

      it { is_expected.to be true }
    end

    context 'when validating a matching string' do
      subject(:validation) { type.not_being_equal_to('hello').validate('hello') }

      it { is_expected.to be false }
    end
  end

  describe '#not_matching' do
    context 'when validating a string not matching any patterns' do
      subject(:validation) { type.not_matching(/\d/, /[A-Z]/).validate('hello') }

      it { is_expected.to be true }
    end

    context 'when validating a string matching some patterns' do
      subject(:validation) { type.not_matching(/\d/, /[A-Z]/).validate('hello123') }

      it { is_expected.to be false }
    end
  end
end
