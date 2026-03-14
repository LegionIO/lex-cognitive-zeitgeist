# lex-cognitive-zeitgeist

A LegionIO cognitive architecture extension that captures the aggregate cognitive atmosphere across subsystems. Named after the German "spirit of the age" — surfaces dominant themes, collective mood, convergence, and momentum from the stream of signals flowing through the cognitive system.

## What It Does

Ingests **cognitive signals** from multiple subsystems and computes cross-cutting metrics:

- **Collective mood**: intensity-weighted mean valence across all signals (-1.0 to +1.0)
- **Cognitive convergence**: ratio of subsystems focused on the same dominant domain; low convergence triggers a divergence alert
- **Momentum**: whether signal intensity is accelerating or fading in the recent window
- **Dominant themes**: domains with highest total intensity weight
- **Rising/falling domains**: comparing recent activity to historical baseline

## Usage

```ruby
require 'lex-cognitive-zeitgeist'

client = Legion::Extensions::CognitiveZeitgeist::Client.new

# Ingest signals from different subsystems
client.ingest_signal(source_subsystem: :emotion, domain: :anxiety, intensity: 0.7, valence: -0.6)
client.ingest_signal(source_subsystem: :prediction, domain: :threat, intensity: 0.8, valence: -0.4)
client.ingest_signal(source_subsystem: :memory, domain: :curiosity, intensity: 0.5, valence: 0.3)

# Get collective mood
client.collective_mood
# => { success: true, mood: -0.4, mood_label: :subdued }

# Check whether subsystems are aligned
client.cognitive_convergence
# => { success: true, convergence: 0.67, convergence_label: :aligned, divergence_alert: false }

# Dominant themes (by intensity weight)
client.dominant_themes(limit: 3)
# => { success: true, themes: [{ domain: :threat, weight: 0.8 }, ...], count: 3 }

# Rising and falling domains
client.rising_domains
# => { success: true, domains: [{ domain: :threat, delta: 0.3 }], count: 1 }

# Trend window status
client.trend_window_status
# => { success: true, trend_window: { size: 3, dominant_domain: :threat, momentum: 0.1, ... }, momentum_label: :steady }

# Full zeitgeist report
client.zeitgeist_report
# => { success: true, signal_count: 3, dominant_themes: [...], collective_mood: -0.4,
#      mood_label: :subdued, convergence: 0.67, convergence_label: :aligned,
#      momentum: 0.1, momentum_label: :steady, divergence_alert: false, ... }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
