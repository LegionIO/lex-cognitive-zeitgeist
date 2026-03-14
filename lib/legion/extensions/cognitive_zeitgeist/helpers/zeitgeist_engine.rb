# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveZeitgeist
      module Helpers
        class ZeitgeistEngine
          include Constants

          attr_reader :signals, :trend_window

          def initialize
            @signals      = []
            @trend_window = TrendWindow.new
          end

          def ingest(source_subsystem:, domain:, intensity: DEFAULT_INTENSITY, valence: 0.0, timestamp: nil)
            signal = CognitiveSignal.new(
              source_subsystem: source_subsystem,
              domain:           domain,
              intensity:        intensity,
              valence:          valence,
              timestamp:        timestamp
            )
            @signals << signal
            @signals.shift while @signals.size > MAX_SIGNALS
            @trend_window.add(signal)
            signal
          end

          def dominant_themes(limit: 5)
            return [] if @signals.empty?

            weights = Hash.new(0.0)
            @signals.each { |s| weights[s.domain] += s.intensity }
            weights.sort_by { |_d, w| -w }.first(limit).map do |domain, weight|
              { domain: domain, weight: weight.round(10) }
            end
          end

          def collective_mood
            return 0.0 if @signals.empty?

            weighted_sum = @signals.sum { |s| s.valence * s.intensity }
            total = @signals.sum(&:intensity)
            return 0.0 if total.zero?

            (weighted_sum / total).clamp(-1.0, 1.0).round(10)
          end

          def cognitive_convergence
            return 1.0 if @signals.empty?

            subsystems = @signals.map(&:source_subsystem).uniq
            return 1.0 if subsystems.size <= 1

            subsystem_domains = subsystems.to_h do |sub|
              subs_signals = @signals.select { |s| s.source_subsystem == sub }
              dominant = compute_dominant_domain(subs_signals)
              [sub, dominant]
            end

            overall_dominant = dominant_themes(limit: 1).first&.fetch(:domain)
            return 0.5 unless overall_dominant

            aligned = subsystem_domains.count { |_sub, dom| dom == overall_dominant }
            (aligned.to_f / subsystems.size).round(10)
          end

          def rising_domains(window_size: WINDOW_SIZE / 2)
            return [] if @signals.size < window_size

            recent  = @signals.last(window_size)
            earlier = @signals.last(window_size * 2).first(window_size)

            deltas = domain_intensity_deltas(recent, earlier)
            deltas.select { |d| d[:delta] > 0.0 }.sort_by { |d| -d[:delta] }
          end

          def falling_domains(window_size: WINDOW_SIZE / 2)
            return [] if @signals.size < window_size

            recent  = @signals.last(window_size)
            earlier = @signals.last(window_size * 2).first(window_size)

            deltas = domain_intensity_deltas(recent, earlier)
            deltas.select { |d| d[:delta] < 0.0 }.sort_by { |d| d[:delta] }
          end

          def divergence_alert?
            cognitive_convergence < DIVERGENCE_THRESHOLD
          end

          def zeitgeist_report
            mood_value = collective_mood
            conv_value = cognitive_convergence
            mom_value  = @trend_window.momentum

            {
              signal_count:      @signals.size,
              dominant_themes:   dominant_themes,
              collective_mood:   mood_value,
              mood_label:        Constants.label_for(MOOD_LABELS, normalize_mood(mood_value)),
              convergence:       conv_value,
              convergence_label: Constants.label_for(CONVERGENCE_LABELS, conv_value),
              momentum:          mom_value,
              momentum_label:    Constants.label_for(MOMENTUM_LABELS, mom_value),
              rising_domains:    rising_domains,
              falling_domains:   falling_domains,
              divergence_alert:  divergence_alert?,
              trend_window:      @trend_window.to_h
            }
          end

          private

          def compute_dominant_domain(subs_signals)
            return nil if subs_signals.empty?

            weights = Hash.new(0.0)
            subs_signals.each { |s| weights[s.domain] += s.intensity }
            weights.max_by { |_d, w| w }&.first
          end

          def domain_intensity_deltas(recent, earlier)
            recent_weights  = aggregate_domain_weights(recent)
            earlier_weights = aggregate_domain_weights(earlier)

            all_domains = (recent_weights.keys + earlier_weights.keys).uniq
            all_domains.map do |domain|
              r = recent_weights.fetch(domain, 0.0)
              e = earlier_weights.fetch(domain, 0.0)
              { domain: domain, delta: (r - e).round(10) }
            end
          end

          def aggregate_domain_weights(sigs)
            weights = Hash.new(0.0)
            sigs.each { |s| weights[s.domain] += s.intensity }
            weights
          end

          def normalize_mood(mood_value)
            ((mood_value + 1.0) / 2.0).clamp(0.0, 1.0)
          end
        end
      end
    end
  end
end
