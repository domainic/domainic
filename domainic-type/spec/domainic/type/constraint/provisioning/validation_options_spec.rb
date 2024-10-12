# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/constraint/provisioning/validation_options'

RSpec.describe Domainic::Type::Constraint::Provisioning::ValidationOptions do
  describe '#fail_fast?' do
    subject(:fail_fast?) { validation_options.fail_fast? }

    context 'when fail fast is provided and is `true`' do
      let(:validation_options) { described_class.new(fail_fast: true) }

      it { is_expected.to be true }
    end

    context 'when fail fast is not provided' do
      let(:validation_options) { described_class.new }

      it { is_expected.to be false }
    end
  end
end
