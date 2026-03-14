# frozen_string_literal: true

require 'securerandom'

require_relative 'cognitive_zeitgeist/version'
require_relative 'cognitive_zeitgeist/helpers/constants'
require_relative 'cognitive_zeitgeist/helpers/cognitive_signal'
require_relative 'cognitive_zeitgeist/helpers/trend_window'
require_relative 'cognitive_zeitgeist/helpers/zeitgeist_engine'
require_relative 'cognitive_zeitgeist/runners/cognitive_zeitgeist'
require_relative 'cognitive_zeitgeist/helpers/client'

module Legion
  module Extensions
    module CognitiveZeitgeist
      extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core)
    end
  end
end
