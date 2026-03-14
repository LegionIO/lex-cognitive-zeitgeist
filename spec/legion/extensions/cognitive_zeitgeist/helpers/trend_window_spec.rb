# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveZeitgeist::Helpers::TrendWindow do
  subject(:window) { described_class.new }

  let(:signal_class) { Legion::Extensions::CognitiveZeitgeist::Helpers::CognitiveSignal }

  def make_signal(domain: :curiosity, intensity: 0.5, valence: 0.0)
    signal_class.new(source_subsystem: :emotion, domain: domain, intensity: intensity, valence: valence)
  end

  describe '#add' do
    it 'adds a signal and returns self' do
      result = window.add(make_signal)
      expect(result).to be(window)
      expect(window.signals.size).to eq(1)
    end

    it 'evicts oldest signal when at capacity' do
      small_window = described_class.new(window_size: 3)
      4.times { small_window.add(make_signal) }
      expect(small_window.signals.size).to eq(3)
    end
  end

  describe '#dominant_domain' do
    it 'returns nil for empty window' do
      expect(window.dominant_domain).to be_nil
    end

    it 'returns the domain with highest weighted intensity' do
      window.add(make_signal(domain: :threat, intensity: 0.9))
      window.add(make_signal(domain: :threat, intensity: 0.8))
      window.add(make_signal(domain: :curiosity, intensity: 0.3))
      expect(window.dominant_domain).to eq(:threat)
    end
  end

  describe '#dominant_valence' do
    it 'returns 0.0 for empty window' do
      expect(window.dominant_valence).to eq(0.0)
    end

    it 'computes intensity-weighted valence' do
      window.add(make_signal(domain: :threat, intensity: 1.0, valence: -1.0))
      window.add(make_signal(domain: :opportunity, intensity: 1.0, valence: 1.0))
      expect(window.dominant_valence).to be_within(0.001).of(0.0)
    end

    it 'is positive when positive signals dominate' do
      window.add(make_signal(intensity: 0.8, valence: 0.9))
      window.add(make_signal(intensity: 0.1, valence: -0.5))
      expect(window.dominant_valence).to be > 0.0
    end
  end

  describe '#momentum' do
    it 'returns 0.0 with fewer than 2 signals' do
      window.add(make_signal)
      expect(window.momentum).to eq(0.0)
    end

    it 'returns positive momentum when second half more intense' do
      4.times { window.add(make_signal(intensity: 0.2)) }
      4.times { window.add(make_signal(intensity: 0.9)) }
      expect(window.momentum).to be > 0.0
    end

    it 'returns negative momentum when second half less intense' do
      4.times { window.add(make_signal(intensity: 0.9)) }
      4.times { window.add(make_signal(intensity: 0.2)) }
      expect(window.momentum).to be < 0.0
    end
  end

  describe '#accelerating? and #decelerating?' do
    it 'is accelerating when momentum exceeds threshold' do
      4.times { window.add(make_signal(intensity: 0.1)) }
      4.times { window.add(make_signal(intensity: 1.0)) }
      expect(window.accelerating?).to be true
      expect(window.decelerating?).to be false
    end

    it 'is decelerating when momentum is strongly negative' do
      4.times { window.add(make_signal(intensity: 1.0)) }
      4.times { window.add(make_signal(intensity: 0.0)) }
      expect(window.decelerating?).to be true
      expect(window.accelerating?).to be false
    end
  end

  describe '#to_h' do
    it 'returns a complete hash' do
      window.add(make_signal)
      h = window.to_h
      expect(h.keys).to include(:size, :window_size, :dominant_domain, :dominant_valence, :momentum,
                                :accelerating, :decelerating)
    end
  end
end
