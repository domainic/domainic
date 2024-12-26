# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/behavior'
require 'domainic/type/behavior/string_behavior'

RSpec.describe Domainic::Type::Behavior::StringBehavior do
  subject(:type) { test_class.new }

  let(:test_class) do
    Class.new do
      include Domainic::Type::Behavior
      include Domainic::Type::Behavior::StringBehavior

      intrinsically_constrain :self, :type, String, abort_on_failure: true, description: :not_described
    end
  end

  describe '#being_alphanumeric' do
    context 'when validating an alphanumeric string' do
      subject(:validation) { type.being_alphanumeric.validate('abc123') }

      it { is_expected.to be true }
    end

    context 'when validating a non-alphanumeric string' do
      subject(:validation) { type.being_alphanumeric.validate('abc-123') }

      it { is_expected.to be false }
    end
  end

  describe '#being_ascii' do
    context 'when validating an ASCII string' do
      subject(:validation) { type.being_ascii.validate('Hello World!') }

      it { is_expected.to be true }
    end

    context 'when validating a non-ASCII string' do
      subject(:validation) { type.being_ascii.validate('héllo') }

      it { is_expected.to be false }
    end
  end

  describe '#being_empty' do
    context 'when validating an empty string' do
      subject(:validation) { type.being_empty.validate('') }

      it { is_expected.to be true }
    end

    context 'when validating a non-empty string' do
      subject(:validation) { type.being_empty.validate('not empty') }

      it { is_expected.to be false }
    end
  end

  describe '#being_lowercase' do
    context 'when validating a lowercase string' do
      subject(:validation) { type.being_lowercase.validate('hello') }

      it { is_expected.to be true }
    end

    context 'when validating a non-lowercase string' do
      subject(:validation) { type.being_lowercase.validate('Hello') }

      it { is_expected.to be false }
    end
  end

  describe '#being_mixedcase' do
    context 'when validating a mixed case string' do
      subject(:validation) { type.being_mixedcase.validate('helloWORLD') }

      it { is_expected.to be true }
    end

    context 'when validating a single-case string' do
      subject(:validation) { type.being_mixedcase.validate('hello') }

      it { is_expected.to be false }
    end
  end

  describe '#being_only_letters' do
    context 'when validating a letters-only string' do
      subject(:validation) { type.being_only_letters.validate('hello') }

      it { is_expected.to be true }
    end

    context 'when validating a string with non-letters' do
      subject(:validation) { type.being_only_letters.validate('hello123') }

      it { is_expected.to be false }
    end
  end

  describe '#being_only_numbers' do
    context 'when validating a numbers-only string' do
      subject(:validation) { type.being_only_numbers.validate('123') }

      it { is_expected.to be true }
    end

    context 'when validating a string with non-numbers' do
      subject(:validation) { type.being_only_numbers.validate('123abc') }

      it { is_expected.to be false }
    end
  end

  describe '#being_ordered' do
    context 'when validating an ordered string' do
      subject(:validation) { type.being_ordered.validate('abcd') }

      it { is_expected.to be true }
    end

    context 'when validating an unordered string' do
      subject(:validation) { type.being_ordered.validate('dcba') }

      it { is_expected.to be false }
    end
  end

  describe '#being_printable' do
    context 'when validating a printable string' do
      subject(:validation) { type.being_printable.validate('Hello World! @#$%') }

      it { is_expected.to be true }
    end

    context 'when validating a non-printable string' do
      subject(:validation) { type.being_printable.validate("Hello\x00World") }

      it { is_expected.to be false }
    end
  end

  describe '#being_titlecase' do
    context 'when validating a title case string' do
      subject(:validation) { type.being_titlecase.validate('Hello World') }

      it { is_expected.to be true }
    end

    context 'when validating a non-title case string' do
      subject(:validation) { type.being_titlecase.validate('hello world') }

      it { is_expected.to be false }
    end
  end

  describe '#being_uppercase' do
    context 'when validating an uppercase string' do
      subject(:validation) { type.being_uppercase.validate('HELLO') }

      it { is_expected.to be true }
    end

    context 'when validating a non-uppercase string' do
      subject(:validation) { type.being_uppercase.validate('Hello') }

      it { is_expected.to be false }
    end
  end

  describe '#not_being_empty' do
    context 'when validating a non-empty string' do
      subject(:validation) { type.not_being_empty.validate('not empty') }

      it { is_expected.to be true }
    end

    context 'when validating an empty string' do
      subject(:validation) { type.not_being_empty.validate('') }

      it { is_expected.to be false }
    end
  end
end
