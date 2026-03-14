# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveZeitgeist
      module Runners
        module CognitiveZeitgeist
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def ingest_signal(source_subsystem:, domain:, intensity: Helpers::Constants::DEFAULT_INTENSITY,
                            valence: 0.0, engine: nil, **)
            eng     = engine || default_engine
            signal  = eng.ingest(
              source_subsystem: source_subsystem,
              domain:           domain,
              intensity:        intensity,
              valence:          valence
            )
            Legion::Logging.debug "[cognitive_zeitgeist] ingest source=#{source_subsystem} " \
                                  "domain=#{domain} intensity=#{intensity.round(2)} valence=#{valence.round(2)}"
            { success: true, signal: signal.to_h }
          end

          def zeitgeist_report(engine: nil, **)
            eng    = engine || default_engine
            report = eng.zeitgeist_report
            Legion::Logging.debug "[cognitive_zeitgeist] report signals=#{report[:signal_count]} " \
                                  "mood=#{report[:mood_label]} convergence=#{report[:convergence_label]} " \
                                  "momentum=#{report[:momentum_label]}"
            { success: true }.merge(report)
          end

          def collective_mood(engine: nil, **)
            eng   = engine || default_engine
            mood  = eng.collective_mood
            label = Helpers::Constants.label_for(Helpers::Constants::MOOD_LABELS, normalize_mood(mood))
            Legion::Logging.debug "[cognitive_zeitgeist] mood value=#{mood.round(2)} label=#{label}"
            { success: true, mood: mood, mood_label: label }
          end

          def cognitive_convergence(engine: nil, **)
            eng   = engine || default_engine
            conv  = eng.cognitive_convergence
            label = Helpers::Constants.label_for(Helpers::Constants::CONVERGENCE_LABELS, conv)
            alert = eng.divergence_alert?
            Legion::Logging.debug "[cognitive_zeitgeist] convergence value=#{conv.round(2)} label=#{label} " \
                                  "alert=#{alert}"
            { success: true, convergence: conv, convergence_label: label, divergence_alert: alert }
          end

          def dominant_themes(limit: 5, engine: nil, **)
            eng    = engine || default_engine
            themes = eng.dominant_themes(limit: limit)
            Legion::Logging.debug "[cognitive_zeitgeist] dominant_themes count=#{themes.size}"
            { success: true, themes: themes, count: themes.size }
          end

          def rising_domains(engine: nil, **)
            eng     = engine || default_engine
            domains = eng.rising_domains
            Legion::Logging.debug "[cognitive_zeitgeist] rising count=#{domains.size}"
            { success: true, domains: domains, count: domains.size }
          end

          def falling_domains(engine: nil, **)
            eng     = engine || default_engine
            domains = eng.falling_domains
            Legion::Logging.debug "[cognitive_zeitgeist] falling count=#{domains.size}"
            { success: true, domains: domains, count: domains.size }
          end

          def trend_window_status(engine: nil, **)
            eng    = engine || default_engine
            window = eng.trend_window.to_h
            mom_label = Helpers::Constants.label_for(Helpers::Constants::MOMENTUM_LABELS, window[:momentum])
            Legion::Logging.debug "[cognitive_zeitgeist] trend_window size=#{window[:size]} " \
                                  "momentum=#{mom_label}"
            { success: true, trend_window: window, momentum_label: mom_label }
          end

          private

          def default_engine
            @default_engine ||= Helpers::ZeitgeistEngine.new
          end

          def normalize_mood(mood_value)
            ((mood_value + 1.0) / 2.0).clamp(0.0, 1.0)
          end
        end
      end
    end
  end
end
