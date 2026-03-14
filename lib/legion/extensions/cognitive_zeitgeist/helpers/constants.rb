# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveZeitgeist
      module Helpers
        module Constants
          MAX_SIGNALS          = 1000
          WINDOW_SIZE          = 100
          DEFAULT_INTENSITY    = 0.5
          MOMENTUM_THRESHOLD   = 0.3
          CONVERGENCE_THRESHOLD = 0.7
          DIVERGENCE_THRESHOLD = 0.3

          SIGNAL_DOMAINS = %i[
            threat
            opportunity
            curiosity
            anxiety
            creativity
            routine
            social
            abstract
          ].freeze

          MOOD_LABELS = {
            (0.8..)     => :euphoric,
            (0.6...0.8) => :elevated,
            (0.4...0.6) => :neutral,
            (0.2...0.4) => :subdued,
            (..0.2)     => :suppressed
          }.freeze

          CONVERGENCE_LABELS = {
            (0.8..)     => :unified,
            (0.6...0.8) => :aligned,
            (0.4...0.6) => :mixed,
            (0.2...0.4) => :fragmented,
            (..0.2)     => :divergent
          }.freeze

          MOMENTUM_LABELS = {
            (0.6..)      => :surging,
            (0.3...0.6)  => :building,
            (0.0...0.3)  => :steady,
            (-0.3...0.0) => :fading,
            (..-0.3)     => :collapsing
          }.freeze

          def self.label_for(labels_hash, value)
            labels_hash.each do |range, label|
              return label if range.cover?(value)
            end
            nil
          end
        end
      end
    end
  end
end
