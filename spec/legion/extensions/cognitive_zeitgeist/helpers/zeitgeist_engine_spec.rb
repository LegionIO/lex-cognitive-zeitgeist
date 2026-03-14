# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveZeitgeist::Helpers::ZeitgeistEngine do
  subject(:engine) { described_class.new }

  def ingest(domain: :curiosity, subsystem: :emotion, intensity: 0.5, valence: 0.0)
    engine.ingest(source_subsystem: subsystem, domain: domain, intensity: intensity, valence: valence)
  end

  describe '#ingest' do
    it 'returns a CognitiveSignal' do
      signal = ingest
      expect(signal).to be_a(Legion::Extensions::CognitiveZeitgeist::Helpers::CognitiveSignal)
    end

    it 'accumulates signals' do
      3.times { ingest }
      expect(engine.signals.size).to eq(3)
    end

    it 'caps signals at MAX_SIGNALS' do
      stub_const('Legion::Extensions::CognitiveZeitgeist::Helpers::Constants::MAX_SIGNALS', 3)
      4.times { ingest }
      expect(engine.signals.size).to eq(3)
    end
  end

  describe '#dominant_themes' do
    it 'returns empty array with no signals' do
      expect(engine.dominant_themes).to eq([])
    end

    it 'returns themes sorted by weight descending' do
      3.times { ingest(domain: :threat, intensity: 0.9) }
      1.times { ingest(domain: :curiosity, intensity: 0.1) }
      themes = engine.dominant_themes
      expect(themes.first[:domain]).to eq(:threat)
    end

    it 'respects limit parameter' do
      %i[threat curiosity creativity social abstract].each { |d| ingest(domain: d) }
      themes = engine.dominant_themes(limit: 3)
      expect(themes.size).to eq(3)
    end
  end

  describe '#collective_mood' do
    it 'returns 0.0 with no signals' do
      expect(engine.collective_mood).to eq(0.0)
    end

    it 'returns positive mood for positive valence signals' do
      3.times { ingest(valence: 0.8, intensity: 1.0) }
      expect(engine.collective_mood).to be > 0.0
    end

    it 'returns negative mood for negative valence signals' do
      3.times { ingest(valence: -0.8, intensity: 1.0) }
      expect(engine.collective_mood).to be < 0.0
    end

    it 'is weighted by intensity' do
      ingest(valence: 1.0, intensity: 0.9)
      ingest(valence: -1.0, intensity: 0.1)
      expect(engine.collective_mood).to be > 0.0
    end
  end

  describe '#cognitive_convergence' do
    it 'returns 1.0 with no signals' do
      expect(engine.cognitive_convergence).to eq(1.0)
    end

    it 'returns 1.0 with single subsystem' do
      3.times { ingest(domain: :curiosity, subsystem: :emotion) }
      expect(engine.cognitive_convergence).to eq(1.0)
    end

    it 'returns high convergence when subsystems agree on domain' do
      3.times { ingest(domain: :threat, subsystem: :emotion, intensity: 0.9) }
      3.times { ingest(domain: :threat, subsystem: :prediction, intensity: 0.9) }
      3.times { ingest(domain: :threat, subsystem: :memory, intensity: 0.9) }
      expect(engine.cognitive_convergence).to be > 0.5
    end

    it 'returns low convergence when subsystems disagree' do
      3.times { ingest(domain: :threat, subsystem: :emotion, intensity: 0.9) }
      3.times { ingest(domain: :creativity, subsystem: :prediction, intensity: 0.9) }
      3.times { ingest(domain: :social, subsystem: :memory, intensity: 0.9) }
      expect(engine.cognitive_convergence).to be < 0.7
    end
  end

  describe '#rising_domains' do
    it 'returns empty with insufficient signals' do
      expect(engine.rising_domains).to eq([])
    end

    it 'identifies rising domains' do
      constants = Legion::Extensions::CognitiveZeitgeist::Helpers::Constants
      (constants::WINDOW_SIZE / 2).times { ingest(domain: :curiosity, intensity: 0.1) }
      (constants::WINDOW_SIZE / 2).times { ingest(domain: :curiosity, intensity: 0.9) }
      rising = engine.rising_domains
      domains = rising.map { |d| d[:domain] }
      expect(domains).to include(:curiosity)
    end
  end

  describe '#falling_domains' do
    it 'returns empty with insufficient signals' do
      expect(engine.falling_domains).to eq([])
    end

    it 'identifies falling domains' do
      constants = Legion::Extensions::CognitiveZeitgeist::Helpers::Constants
      (constants::WINDOW_SIZE / 2).times { ingest(domain: :anxiety, intensity: 0.9) }
      (constants::WINDOW_SIZE / 2).times { ingest(domain: :anxiety, intensity: 0.1) }
      falling = engine.falling_domains
      domains = falling.map { |d| d[:domain] }
      expect(domains).to include(:anxiety)
    end
  end

  describe '#divergence_alert?' do
    it 'returns false when convergence is high' do
      3.times { ingest(domain: :threat, subsystem: :emotion) }
      3.times { ingest(domain: :threat, subsystem: :prediction) }
      expect(engine.divergence_alert?).to be false
    end
  end

  describe '#zeitgeist_report' do
    before do
      3.times { ingest(domain: :threat, subsystem: :emotion, intensity: 0.8, valence: -0.6) }
      2.times { ingest(domain: :curiosity, subsystem: :prediction, intensity: 0.4, valence: 0.3) }
    end

    it 'returns a complete report hash' do
      report = engine.zeitgeist_report
      expect(report.keys).to include(
        :signal_count, :dominant_themes, :collective_mood, :mood_label,
        :convergence, :convergence_label, :momentum, :momentum_label,
        :rising_domains, :falling_domains, :divergence_alert, :trend_window
      )
    end

    it 'includes signal count' do
      expect(engine.zeitgeist_report[:signal_count]).to eq(5)
    end

    it 'includes a mood label' do
      expect(engine.zeitgeist_report[:mood_label]).to be_a(Symbol)
    end

    it 'includes a convergence label' do
      expect(engine.zeitgeist_report[:convergence_label]).to be_a(Symbol)
    end

    it 'includes a momentum label' do
      expect(engine.zeitgeist_report[:momentum_label]).to be_a(Symbol).or be_nil
    end
  end
end
