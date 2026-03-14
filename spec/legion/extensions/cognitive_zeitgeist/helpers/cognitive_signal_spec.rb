# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveZeitgeist::Helpers::CognitiveSignal do
  subject(:signal) do
    described_class.new(source_subsystem: :emotion, domain: :threat, intensity: 0.8, valence: -0.5)
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(signal.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores source_subsystem as symbol' do
      expect(signal.source_subsystem).to eq(:emotion)
    end

    it 'stores domain as symbol' do
      expect(signal.domain).to eq(:threat)
    end

    it 'clamps intensity to 0..1' do
      s = described_class.new(source_subsystem: :x, domain: :y, intensity: 5.0)
      expect(s.intensity).to eq(1.0)
    end

    it 'clamps valence to -1..1' do
      s = described_class.new(source_subsystem: :x, domain: :y, valence: -9.0)
      expect(s.valence).to eq(-1.0)
    end

    it 'uses default intensity when not provided' do
      s = described_class.new(source_subsystem: :x, domain: :y)
      expect(s.intensity).to eq(Legion::Extensions::CognitiveZeitgeist::Helpers::Constants::DEFAULT_INTENSITY)
    end

    it 'defaults timestamp to now' do
      expect(signal.timestamp).to be_a(Time)
    end

    it 'accepts explicit timestamp' do
      t = Time.now.utc - 3600
      s = described_class.new(source_subsystem: :x, domain: :y, timestamp: t)
      expect(s.timestamp).to eq(t)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all fields' do
      h = signal.to_h
      expect(h.keys).to contain_exactly(:id, :source_subsystem, :domain, :intensity, :valence, :timestamp)
    end

    it 'rounds intensity to 10 decimal places' do
      h = signal.to_h
      expect(h[:intensity]).to be_a(Float)
    end

    it 'includes timestamp as iso8601 string' do
      expect(signal.to_h[:timestamp]).to match(/\d{4}-\d{2}-\d{2}/)
    end
  end
end
