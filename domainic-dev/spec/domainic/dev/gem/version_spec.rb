# frozen_string_literal: true

RSpec.describe Domainic::Dev::Gem::Version do
  describe '.new' do
    subject(:version) { described_class.new(version_string) }

    context 'with valid version strings' do
      {
        '1.2.3' => [1, 2, 3, nil, nil],
        '0.0.1' => [0, 0, 1, nil, nil],
        '1.0.0-alpha' => [1, 0, 0, 'alpha', nil],
        '1.0.0-alpha.1' => [1, 0, 0, 'alpha.1', nil],
        '1.0.0+build.123' => [1, 0, 0, nil, 'build.123'],
        '1.0.0-beta+build.123' => [1, 0, 0, 'beta', 'build.123']
      }.each do |version_string, (major, minor, patch, pre, build)|
        context "with #{version_string}" do
          let(:version_string) { version_string }

          it "is expected to set major to #{major}" do
            expect(version.major).to eq(major)
          end

          it "is expected to set minor to #{minor}" do
            expect(version.minor).to eq(minor)
          end

          it "is expected to set patch to #{patch}" do
            expect(version.patch).to eq(patch)
          end

          it "is expected to set pre to #{pre.inspect}" do
            expect(version.pre).to eq(pre)
          end

          it "is expected to set build to #{build.inspect}" do
            expect(version.build).to eq(build)
          end
        end
      end
    end

    context 'with invalid version strings' do
      %w[1 1.2 1.2.3.4 1.2.3- 1.2.3+ 01.2.3 1.02.3 1.2.03].each do |invalid_version|
        let(:version_string) { invalid_version }

        it "is expected to raise ArgumentError for #{invalid_version}" do
          expect { version }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe '#<=>' do
    subject(:comparison) { version <=> other }

    let(:version) { described_class.new(version_string) }
    let(:other) { described_class.new(other_version) }

    context 'with regular versions' do
      let(:version_string) { '1.0.0' }

      {
        '0.9.9' => 1,
        '1.0.0' => 0,
        '1.0.1' => -1,
        '0.9.0' => 1,
        '2.0.0' => -1
      }.each do |other_ver, expected_result|
        context "when comparing with #{other_ver}" do
          let(:other_version) { other_ver }

          it "is expected to return #{expected_result}" do
            expect(comparison).to eq(expected_result)
          end
        end
      end
    end

    context 'with pre-release versions' do
      let(:version_string) { '1.0.0-alpha' }

      {
        '1.0.0-alpha' => 0,
        '1.0.0' => -1,
        '1.0.0-alpha.1' => -1,
        '1.0.0-alpha.beta' => -1,
        '1.0.0-beta' => -1,
        '1.0.0-beta.2' => -1,
        '1.0.0-beta.11' => -1,
        '1.0.0-rc.1' => -1
      }.each do |other_ver, expected_result|
        context "when comparing with #{other_ver}" do
          let(:other_version) { other_ver }

          it "is expected to return #{expected_result}" do
            expect(comparison).to eq(expected_result)
          end
        end
      end
    end

    context 'when comparing with non-Version objects' do
      let(:version_string) { '1.0.0' }
      let(:other) { '1.0.0' }

      it 'is expected to return nil' do
        expect(comparison).to be_nil
      end
    end
  end

  describe '#eql?' do
    subject(:equality) { version.eql?(other) }

    let(:version) { described_class.new(version_string) }
    let(:version_string) { '1.0.0-alpha+build.123' }

    context 'with an identical version' do
      let(:other) { described_class.new(version_string) }

      it 'is expected to return true' do
        expect(equality).to be true
      end
    end

    context 'with a different version' do
      let(:other) { described_class.new('1.0.0-beta+build.123') }

      it 'is expected to return false' do
        expect(equality).to be false
      end
    end
  end

  describe '#to_array' do
    subject(:array) { version.to_array }

    let(:version) { described_class.new(version_string) }
    let(:version_string) { '1.2.3-alpha+build.123' }

    it 'is expected to return the correct array representation' do
      expect(array).to eq([1, 2, 3, 'alpha', 'build.123'])
    end
  end

  describe '#to_hash' do
    subject(:hash) { version.to_hash }

    let(:version) { described_class.new(version_string) }
    let(:version_string) { '1.2.3-alpha+build.123' }

    it 'is expected to return the correct hash representation' do
      expect(hash).to eq({
                           major: 1,
                           minor: 2,
                           patch: 3,
                           pre: 'alpha',
                           build: 'build.123'
                         })
    end
  end

  describe '#to_gem_version_string' do
    subject(:gem_version) { version.to_gem_version_string }

    let(:version) { described_class.new(version_string) }
    let(:version_string) { '1.2.3-alpha+build.123' }

    it 'is expected to return the correct gem version string' do
      expect(gem_version).to eq('1.2.3.alpha.build.123')
    end
  end

  describe '#to_semver_string' do
    subject(:semver) { version.to_semver_string }

    let(:version) { described_class.new(version_string) }
    let(:version_string) { '1.2.3-alpha+build.123' }

    it 'is expected to return the correct semver string' do
      expect(semver).to eq('1.2.3-alpha+build.123')
    end
  end
end
