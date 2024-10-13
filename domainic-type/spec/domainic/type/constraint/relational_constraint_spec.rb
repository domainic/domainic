# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/relational_constraint'

RSpec.describe Domainic::Type::Constraint::RelationalConstraint do
  let(:constraint_class) do
    Class.new(described_class) do
      def self.name
        'TestConstraint'
      end

      expectation :test
    end
  end

  describe '.expectation' do
    subject(:expectation) { constraint_class.expectation(value) }

    let(:value) { :new_value }

    it 'is expected to set the expectation for the class' do
      expect { expectation }.to change { constraint_class.instance_variable_get(:@expectation) }.to(value)
    end
  end
end
