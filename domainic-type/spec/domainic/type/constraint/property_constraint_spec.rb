# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'
require 'domainic/type/constraint/property_constraint'

RSpec.describe Domainic::Type::Constraint::PropertyConstraint do
  describe '.conditions' do
    subject(:conditions) { constraint_class.conditions(*expected_conditions) }

    let(:constraint_class) { Class.new(described_class) }
    let(:expected_conditions) { %i[condition_one condition_two] }

    it {
      expect { conditions }.to(
        change(constraint_class, :valid_conditions).to(expected_conditions.map { |c| :"#{c}?" })
      )
    }
  end

  describe '#condition' do
    subject(:condition) { constraint.condition }

    let(:constraint) do
      klass = Class.new(described_class) do
        def self.name
          'TestConstraint'
        end

        conditions :condition_one, :condition_two
      end
      klass.new(instance_double(Domainic::Type::BaseType))
    end

    it { is_expected.to be_nil }

    context 'when set' do
      subject(:condition) { constraint.condition = :condition_one }

      it { expect { condition }.to change(constraint, :condition).to(:condition_one?) }
    end
  end

  describe '#condition=' do
    subject(:set_condition) { constraint.condition = expected_condition }

    let(:constraint) do
      klass = Class.new(described_class) do
        def self.name
          'TestConstraint'
        end

        conditions :condition_one, :condition_two
      end
      klass.new(instance_double(Domainic::Type::BaseType))
    end

    context 'when the condition is valid' do
      let(:expected_condition) { constraint.class.valid_conditions.sample }

      it { expect { set_condition }.to change(constraint, :condition).to(expected_condition) }
    end

    context 'when the condition is invalid' do
      let(:expected_condition) { :invalid_condition }

      it { expect { set_condition }.to raise_error(Domainic::Type::InvalidParameterError) }
    end
  end
end
