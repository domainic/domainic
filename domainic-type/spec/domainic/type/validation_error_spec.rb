# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/behavior'
require 'domainic/type/validation_error'

RSpec.describe Domainic::Type::ValidationError do
  describe '.details_for' do
    subject(:details) { described_class.details_for(type, failures, actual) }

    let(:type) { instance_double(Object, inspect: 'TestType') }
    let(:actual) { 123 }

    context 'with no failures' do
      let(:failures) { [] }

      it 'returns only the type mismatch message' do
        expect(details).to eq('Expected a TestType got an Integer')
      end
    end

    context 'with constraint failures' do
      let(:constraint_one) do
        instance_double(
          Domainic::Type::Constraint::Behavior,
          type_failure?: false,
          description: 'length >= 5',
          failure_description: 'length of 3'
        )
      end

      let(:constraint_two) do
        instance_double(
          Domainic::Type::Constraint::Behavior,
          type_failure?: false,
          description: 'format /\\w+/',
          failure_description: '123'
        )
      end

      let(:failures) { [constraint_one, constraint_two] }

      it 'includes all non-type failure messages' do
        expect(details).to eq(
          "Expected a TestType got an Integer\n  " \
          "- Expected length >= 5, but got length of 3\n  " \
          '- Expected format /\\w+/, but got 123'
        )
      end
    end

    context 'with type failures' do
      let(:type_constraint) do
        instance_double(
          Domainic::Type::Constraint::Behavior,
          type_failure?: true,
          description: 'a String',
          failure_description: 'Integer'
        )
      end

      let(:other_constraint) do
        instance_double(
          Domainic::Type::Constraint::Behavior,
          type_failure?: false,
          description: 'length >= 5',
          failure_description: 'length of 3'
        )
      end

      let(:failures) { [type_constraint, other_constraint] }

      it 'excludes type failure messages' do
        expect(details).to eq(
          "Expected a TestType got an Integer\n  " \
          '- Expected length >= 5, but got length of 3'
        )
      end
    end

    context 'with vowel-starting class names' do
      let(:failures) { [] }
      let(:type) { instance_double(Object, inspect: 'IntegerType') }

      it 'uses correct articles' do
        expect(details).to eq('Expected an IntegerType got an Integer')
      end
    end
  end
end
