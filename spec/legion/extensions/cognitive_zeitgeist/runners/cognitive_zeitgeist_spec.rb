# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveZeitgeist::Runners::CognitiveZeitgeist do
  let(:client) { Legion::Extensions::CognitiveZeitgeist::Helpers::Client.new }
  let(:engine) { Legion::Extensions::CognitiveZeitgeist::Helpers::ZeitgeistEngine.new }

  def ingest(domain: :curiosity, subsystem: :emotion, intensity: 0.5, valence: 0.0)
    client.ingest_signal(source_subsystem: subsystem, domain: domain,
                         intensity: intensity, valence: valence, engine: engine)
  end

  describe '#ingest_signal' do
    it 'returns success true' do
      result = client.ingest_signal(source_subsystem: :emotion, domain: :curiosity)
      expect(result[:success]).to be true
    end

    it 'returns signal hash' do
      result = client.ingest_signal(source_subsystem: :emotion, domain: :curiosity)
      expect(result[:signal]).to be_a(Hash)
      expect(result[:signal][:domain]).to eq(:curiosity)
    end

    it 'accepts injected engine' do
      result = ingest(domain: :threat, intensity: 0.9)
      expect(result[:success]).to be true
      expect(engine.signals.size).to eq(1)
    end

    it 'uses default intensity when not provided' do
      result = client.ingest_signal(source_subsystem: :emotion, domain: :social)
      constants = Legion::Extensions::CognitiveZeitgeist::Helpers::Constants
      expect(result[:signal][:intensity]).to eq(constants::DEFAULT_INTENSITY)
    end
  end

  describe '#zeitgeist_report' do
    before do
      3.times { ingest(domain: :threat, subsystem: :emotion, intensity: 0.8, valence: -0.5) }
    end

    it 'returns success true' do
      result = client.zeitgeist_report(engine: engine)
      expect(result[:success]).to be true
    end

    it 'includes signal_count' do
      result = client.zeitgeist_report(engine: engine)
      expect(result[:signal_count]).to eq(3)
    end

    it 'includes dominant_themes' do
      result = client.zeitgeist_report(engine: engine)
      expect(result[:dominant_themes]).to be_an(Array)
    end

    it 'includes mood_label' do
      result = client.zeitgeist_report(engine: engine)
      expect(result[:mood_label]).to be_a(Symbol)
    end
  end

  describe '#collective_mood' do
    it 'returns success true' do
      result = client.collective_mood(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns mood value' do
      expect(client.collective_mood(engine: engine)[:mood]).to be_a(Float)
    end

    it 'returns mood_label' do
      ingest(domain: :threat, valence: -0.9, intensity: 1.0)
      result = client.collective_mood(engine: engine)
      expect(result[:mood_label]).to be_a(Symbol)
    end
  end

  describe '#cognitive_convergence' do
    it 'returns success true' do
      result = client.cognitive_convergence(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns convergence value' do
      expect(client.cognitive_convergence(engine: engine)[:convergence]).to be_a(Float)
    end

    it 'returns convergence_label' do
      result = client.cognitive_convergence(engine: engine)
      expect(result[:convergence_label]).to be_a(Symbol)
    end

    it 'returns divergence_alert boolean' do
      result = client.cognitive_convergence(engine: engine)
      expect(result[:divergence_alert]).to be(true).or be(false)
    end
  end

  describe '#dominant_themes' do
    it 'returns success true' do
      result = client.dominant_themes(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns themes array and count' do
      ingest(domain: :curiosity)
      result = client.dominant_themes(engine: engine)
      expect(result[:themes]).to be_an(Array)
      expect(result[:count]).to eq(result[:themes].size)
    end

    it 'respects limit' do
      %i[threat curiosity creativity social abstract routine].each do |d|
        ingest(domain: d)
      end
      result = client.dominant_themes(limit: 2, engine: engine)
      expect(result[:count]).to eq(2)
    end
  end

  describe '#rising_domains' do
    it 'returns success true' do
      result = client.rising_domains(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns domains array with count' do
      result = client.rising_domains(engine: engine)
      expect(result[:domains]).to be_an(Array)
      expect(result[:count]).to eq(result[:domains].size)
    end
  end

  describe '#falling_domains' do
    it 'returns success true' do
      result = client.falling_domains(engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns domains array with count' do
      result = client.falling_domains(engine: engine)
      expect(result[:domains]).to be_an(Array)
    end
  end

  describe '#trend_window_status' do
    it 'returns success true' do
      result = client.trend_window_status(engine: engine)
      expect(result[:success]).to be true
    end

    it 'includes trend_window hash' do
      result = client.trend_window_status(engine: engine)
      expect(result[:trend_window]).to be_a(Hash)
    end

    it 'includes momentum_label' do
      ingest
      result = client.trend_window_status(engine: engine)
      expect(result[:momentum_label]).to be_a(Symbol).or be_nil
    end
  end
end
