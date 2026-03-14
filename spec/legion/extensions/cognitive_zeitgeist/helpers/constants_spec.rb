# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveZeitgeist::Helpers::Constants do
  describe '.label_for' do
    it 'returns correct mood label for high value' do
      label = described_class.label_for(described_class::MOOD_LABELS, 0.9)
      expect(label).to eq(:euphoric)
    end

    it 'returns correct mood label for mid value' do
      label = described_class.label_for(described_class::MOOD_LABELS, 0.5)
      expect(label).to eq(:neutral)
    end

    it 'returns correct mood label for low value' do
      label = described_class.label_for(described_class::MOOD_LABELS, 0.1)
      expect(label).to eq(:suppressed)
    end

    it 'returns correct convergence label for unified' do
      label = described_class.label_for(described_class::CONVERGENCE_LABELS, 0.95)
      expect(label).to eq(:unified)
    end

    it 'returns correct convergence label for divergent' do
      label = described_class.label_for(described_class::CONVERGENCE_LABELS, 0.1)
      expect(label).to eq(:divergent)
    end

    it 'returns correct momentum label for surging' do
      label = described_class.label_for(described_class::MOMENTUM_LABELS, 0.8)
      expect(label).to eq(:surging)
    end

    it 'returns correct momentum label for collapsing' do
      label = described_class.label_for(described_class::MOMENTUM_LABELS, -0.5)
      expect(label).to eq(:collapsing)
    end

    it 'returns nil for unmatched value when no range covers it' do
      custom = { (0.5..1.0) => :high }.freeze
      expect(described_class.label_for(custom, 0.2)).to be_nil
    end
  end

  describe 'SIGNAL_DOMAINS' do
    it 'contains 8 domains' do
      expect(described_class::SIGNAL_DOMAINS.size).to eq(8)
    end

    it 'includes expected domains' do
      expect(described_class::SIGNAL_DOMAINS).to include(:threat, :curiosity, :creativity, :social)
    end
  end

  describe 'constants' do
    it 'MAX_SIGNALS is 1000' do
      expect(described_class::MAX_SIGNALS).to eq(1000)
    end

    it 'WINDOW_SIZE is 100' do
      expect(described_class::WINDOW_SIZE).to eq(100)
    end

    it 'CONVERGENCE_THRESHOLD is 0.7' do
      expect(described_class::CONVERGENCE_THRESHOLD).to eq(0.7)
    end

    it 'DIVERGENCE_THRESHOLD is 0.3' do
      expect(described_class::DIVERGENCE_THRESHOLD).to eq(0.3)
    end
  end
end
