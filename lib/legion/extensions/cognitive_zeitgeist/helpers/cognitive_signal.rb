# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveZeitgeist
      module Helpers
        class CognitiveSignal
          attr_reader :id, :source_subsystem, :domain, :intensity, :valence, :timestamp

          def initialize(source_subsystem:, domain:, intensity: Constants::DEFAULT_INTENSITY,
                         valence: 0.0, timestamp: nil)
            @id               = SecureRandom.uuid
            @source_subsystem = source_subsystem.to_sym
            @domain           = domain.to_sym
            @intensity        = intensity.to_f.clamp(0.0, 1.0)
            @valence          = valence.to_f.clamp(-1.0, 1.0)
            @timestamp        = timestamp || Time.now.utc
          end

          def to_h
            {
              id:               @id,
              source_subsystem: @source_subsystem,
              domain:           @domain,
              intensity:        @intensity.round(10),
              valence:          @valence.round(10),
              timestamp:        @timestamp.iso8601
            }
          end
        end
      end
    end
  end
end
