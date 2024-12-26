# frozen_string_literal: true

require 'spec_helper'
require 'domainic/type/types/identifier/cuid_type'

RSpec.describe Domainic::Type::CUIDType do
  let(:type) { described_class.new }

  describe '.validate' do
    subject(:validate) { type.validate(cuid) }

    context 'when validating a valid CUID v1' do
      let(:cuid) { 'ch72gsb320000udocl363eofy' }

      it { is_expected.to be true }
    end

    context 'when validating a valid CUID v2' do
      let(:cuid) { 'la6m1dv00000gv25zp9ru12g' }

      it { is_expected.to be true }
    end

    context 'when validating an invalid CUID' do
      let(:cuid) { 'not-a-cuid' }

      it { is_expected.to be false }
    end

    context 'when validating a non-string' do
      let(:cuid) { :symbol }

      it { is_expected.to be false }
    end
  end

  describe '.validate!' do
    subject(:validate!) { type.validate!(cuid) }

    context 'when validating a valid CUID v1' do
      let(:cuid) { 'ch72gsb320000udocl363eofy' }

      it { is_expected.to be true }
    end

    context 'when validating a valid CUID v2' do
      let(:cuid) { 'la6m1dv00000gv25zp9ru12g' }

      it { is_expected.to be true }
    end

    context 'when validating an invalid CUID' do
      let(:cuid) { 'not-a-cuid' }

      it { expect { validate! }.to raise_error(TypeError, /Expected CUID/) }
    end
  end

  describe '#being_version_one' do
    subject(:being_version_one) { type.being_version_one.validate(cuid) }

    context 'when CUID is v1' do
      let(:cuid) { 'ch72gsb320000udocl363eofy' }

      it { is_expected.to be true }
    end

    context 'when CUID is v2' do
      let(:cuid) { 'la6m1dv00000gv25zp9ru12g' }

      it { is_expected.to be false }
    end

    context 'when CUID is invalid' do
      let(:cuid) { 'not-a-cuid' }

      it { is_expected.to be false }
    end
  end

  describe '#being_version_two' do
    subject(:being_version_two) { type.being_version_two.validate(cuid) }

    context 'when CUID is v2' do
      let(:cuid) { 'la6m1dv00000gv25zp9ru12g' }

      it { is_expected.to be true }
    end

    context 'when CUID is v1' do
      let(:cuid) { 'ch72gsb320000udocl363eofy' }

      it { is_expected.to be false }
    end

    context 'when CUID is invalid' do
      let(:cuid) { 'not-a-cuid' }

      it { is_expected.to be false }
    end
  end

  describe '#being_version' do
    subject(:being_version) { type.being_version(version).validate(cuid) }

    context 'with version 1' do
      let(:version) { 1 }

      context 'when CUID is v1' do
        let(:cuid) { 'ch72gsb320000udocl363eofy' }

        it { is_expected.to be true }
      end

      context 'when CUID is v2' do
        let(:cuid) { 'la6m1dv00000gv25zp9ru12g' }

        it { is_expected.to be false }
      end
    end

    context 'with version 2' do
      let(:version) { 2 }

      context 'when CUID is v2' do
        let(:cuid) { 'la6m1dv00000gv25zp9ru12g' }

        it { is_expected.to be true }
      end

      context 'when CUID is v1' do
        let(:cuid) { 'ch72gsb320000udocl363eofy' }

        it { is_expected.to be false }
      end
    end

    context 'with invalid version' do
      let(:version) { 3 }
      let(:cuid) { 'ch72gsb320000udocl363eofy' }

      it 'raises ArgumentError' do
        expect { being_version }.to raise_error(ArgumentError, /Invalid version/)
      end
    end
  end
end
