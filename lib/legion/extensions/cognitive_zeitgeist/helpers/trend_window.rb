# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveZeitgeist
      module Helpers
        class TrendWindow
          include Constants

          attr_reader :signals, :window_size

          def initialize(window_size: WINDOW_SIZE)
            @signals     = []
            @window_size = window_size
          end

          def add(signal)
            @signals << signal
            @signals.shift while @signals.size > @window_size
            self
          end

          def dominant_domain
            return nil if @signals.empty?

            counts = Hash.new(0.0)
            @signals.each { |s| counts[s.domain] += s.intensity }
            counts.max_by { |_d, weight| weight }&.first
          end

          def dominant_valence
            return 0.0 if @signals.empty?

            weighted_sum = @signals.sum { |s| s.valence * s.intensity }
            total_intensity = @signals.sum(&:intensity)
            return 0.0 if total_intensity.zero?

            (weighted_sum / total_intensity).clamp(-1.0, 1.0).round(10)
          end

          def momentum
            return 0.0 if @signals.size < 2

            half = @signals.size / 2
            first_half  = @signals.first(half)
            second_half = @signals.last(half)

            avg_intensity = ->(arr) { arr.sum(&:intensity) / arr.size.to_f }
            delta = avg_intensity.call(second_half) - avg_intensity.call(first_half)
            delta.clamp(-1.0, 1.0).round(10)
          end

          def accelerating?
            momentum > MOMENTUM_THRESHOLD
          end

          def decelerating?
            momentum < -MOMENTUM_THRESHOLD
          end

          def to_h
            {
              size:             @signals.size,
              window_size:      @window_size,
              dominant_domain:  dominant_domain,
              dominant_valence: dominant_valence,
              momentum:         momentum,
              accelerating:     accelerating?,
              decelerating:     decelerating?
            }
          end
        end
      end
    end
  end
end
