# lex-cognitive-zeitgeist

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-zeitgeist`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::CognitiveZeitgeist`

## Purpose

Captures the aggregate "spirit of the moment" across cognitive subsystems by ingesting signals from multiple sources and computing collective mood, convergence, and momentum. Named after the German concept of the "spirit of the age" — the pervasive cognitive atmosphere emerging from all active subsystem signals rather than any individual source. Surfaces dominant themes, rising/falling domain trends, and alerts when subsystems diverge.

## Gem Info

- **Gemspec**: `lex-cognitive-zeitgeist.gemspec`
- **Require**: `lex-cognitive-zeitgeist`
- **Ruby**: >= 3.4
- **License**: MIT
- **Homepage**: https://github.com/LegionIO/lex-cognitive-zeitgeist

## File Structure

```
lib/legion/extensions/cognitive_zeitgeist/
  version.rb
  helpers/
    constants.rb          # Signal domains, label tables for mood/convergence/momentum
    cognitive_signal.rb   # CognitiveSignal class — one subsystem signal
    trend_window.rb       # TrendWindow — sliding window over recent signals
    zeitgeist_engine.rb   # ZeitgeistEngine — registry, analytics
    client.rb             # Client lives at helpers/client.rb (unusual location)
  runners/
    cognitive_zeitgeist.rb  # Runner module — public API
```

Note: `client.rb` is at `helpers/client.rb`, not the standard `lib/legion/extensions/cognitive_zeitgeist/client.rb`.

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_SIGNALS` | 1000 | Ring buffer for all ingested signals |
| `WINDOW_SIZE` | 100 | Sliding window size for `TrendWindow` |
| `DEFAULT_INTENSITY` | 0.5 | Default signal intensity |
| `MOMENTUM_THRESHOLD` | 0.3 | Absolute momentum threshold for `accelerating?` / `decelerating?` |
| `CONVERGENCE_THRESHOLD` | 0.7 | `convergence_alert?` if above this (not used — see `DIVERGENCE_THRESHOLD`) |
| `DIVERGENCE_THRESHOLD` | 0.3 | `divergence_alert?` if cognitive_convergence < this |

`SIGNAL_DOMAINS`: `[:threat, :opportunity, :curiosity, :anxiety, :creativity, :routine, :social, :abstract]`

Mood labels (applied to normalized valence, -1..1 mapped to 0..1): `0.8+` = `:euphoric`, `0.6..0.8` = `:elevated`, `0.4..0.6` = `:neutral`, `0.2..0.4` = `:subdued`, `< 0.2` = `:suppressed`

Convergence labels: `0.8+` = `:unified`, `0.6..0.8` = `:aligned`, `0.4..0.6` = `:mixed`, `0.2..0.4` = `:fragmented`, `< 0.2` = `:divergent`

Momentum labels (can be negative): `0.6+` = `:surging`, `0.3..0.6` = `:building`, `0.0..0.3` = `:steady`, `-0.3..0.0` = `:fading`, `< -0.3` = `:collapsing`

`Constants.label_for(labels_hash, value)` — iterates hash by range cover; returns nil if no match.

## Key Classes

### `Helpers::CognitiveSignal`

One signal from a cognitive subsystem.

- Fields: `id` (UUID), `source_subsystem` (symbol), `domain` (symbol), `intensity` (0.0–1.0), `valence` (-1.0–1.0), `timestamp`
- `valence` is bidirectional (-1.0 negative through +1.0 positive) — unlike most other extensions which use unsigned intensity

### `Helpers::TrendWindow`

Sliding window (default 100 signals) for local trend analysis.

- `add(signal)` — appends and shifts oldest when over `window_size`; returns `self`
- `dominant_domain` — domain with highest total intensity weight across window signals
- `dominant_valence` — intensity-weighted mean valence across window
- `momentum` — delta between second-half avg intensity and first-half avg intensity; positive = accelerating
- `accelerating?` — momentum > 0.3; `decelerating?` — momentum < -0.3

### `Helpers::ZeitgeistEngine`

Central registry and analytics engine.

- `ingest(source_subsystem:, domain:, intensity:, valence:, timestamp:)` — creates `CognitiveSignal`, appends to `@signals` (ring buffer), adds to `@trend_window`
- `dominant_themes(limit:)` — domains ranked by total intensity weight; returns `[{ domain:, weight: }]`
- `collective_mood` — intensity-weighted mean valence across all signals; returns -1.0..1.0
- `cognitive_convergence` — ratio of subsystems whose dominant domain matches the overall dominant domain; returns 1.0 if <= 1 subsystem; returns 0.5 if no overall dominant found
- `rising_domains(window_size:)` / `falling_domains(window_size:)` — compare recent half to earlier half of signals; return `[{ domain:, delta: }]` sorted by magnitude
- `divergence_alert?` — `cognitive_convergence < DIVERGENCE_THRESHOLD` (0.3)
- `zeitgeist_report` — full report: signal_count, dominant_themes, collective_mood, mood_label, convergence, convergence_label, momentum, momentum_label, rising_domains, falling_domains, divergence_alert, trend_window

Mood normalization: `normalize_mood(mood_value) = (mood + 1.0) / 2.0` — maps -1..1 to 0..1 before label lookup.

## Runners

Module: `Legion::Extensions::CognitiveZeitgeist::Runners::CognitiveZeitgeist`

| Runner | Key Args | Returns |
|---|---|---|
| `ingest_signal` | `source_subsystem:`, `domain:`, `intensity:`, `valence:` | `{ success:, signal: }` |
| `zeitgeist_report` | — | full report merged with `success: true` |
| `collective_mood` | — | `{ success:, mood:, mood_label: }` |
| `cognitive_convergence` | — | `{ success:, convergence:, convergence_label:, divergence_alert: }` |
| `dominant_themes` | `limit:` | `{ success:, themes:, count: }` |
| `rising_domains` | — | `{ success:, domains:, count: }` |
| `falling_domains` | — | `{ success:, domains:, count: }` |
| `trend_window_status` | — | `{ success:, trend_window:, momentum_label: }` |

All runners accept optional `engine:` keyword for test injection.

## Integration Points

- `ingest_signal` should be called by `lex-tick` phase handlers after each phase completes, passing the originating subsystem and domain
- `divergence_alert?` can trigger conflict escalation in `lex-conflict` when subsystems are pulling in incompatible directions
- `collective_mood` provides a cross-subsystem mood aggregate that `lex-emotion` can use to modulate valence
- `dominant_themes` reveals what domains are consuming the most cognitive bandwidth
- All state is in-memory per `ZeitgeistEngine` instance

## Development Notes

- `client.rb` is at `helpers/client.rb` — an unusual location for this gem; not at the standard top-level path
- Valence is signed (-1.0 to 1.0) in this extension; mood label lookup requires normalizing to 0..1 via `(mood + 1.0) / 2.0`
- `cognitive_convergence` returns 1.0 when only one subsystem has ingested signals (no divergence possible) and 0.5 when no overall dominant domain can be determined
- `rising_domains` requires `signals.size >= window_size` (default 50) — returns empty array if insufficient history
- Momentum labels cover negative values (`:fading`, `:collapsing`) — unique among the label tables in this extension category
- `CONVERGENCE_THRESHOLD` (0.7) is defined but not used; only `DIVERGENCE_THRESHOLD` (0.3) drives alert logic
