# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/base_type'

RSpec.describe Domainic::Type::BaseType do
  describe '.constraints' do
    subject(:constraints) { described_class.constraints }

    it { is_expected.to be_an_instance_of(Domainic::Type::Constraint::Provisioning::ConstraintSet) }
  end

  describe '#constraints' do
    subject(:constraints) { type.constraints }

    let(:type) { described_class.new }

    it { is_expected.to be_an_instance_of(Domainic::Type::Constraint::Provisioning::ConstraintSet) }
  end
end
