# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_zeitgeist/version'

Gem::Specification.new do |spec|
  spec.name    = 'lex-cognitive-zeitgeist'
  spec.version = Legion::Extensions::CognitiveZeitgeist::VERSION
  spec.authors = ['Esity']
  spec.email   = ['matthewdiverson@gmail.com']

  spec.summary     = 'Collective cognitive zeitgeist detection for LegionIO agents'
  spec.description = 'Detects the overall mood and trending concerns across all cognitive subsystems. ' \
                     'Captures what the agent mind is collectively focused on via signal ingestion, ' \
                     'trend windows, convergence scoring, and divergence alerts.'
  spec.homepage    = 'https://github.com/LegionIO/lex-cognitive-zeitgeist'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/LegionIO/lex-cognitive-zeitgeist'
  spec.metadata['documentation_uri']     = 'https://github.com/LegionIO/lex-cognitive-zeitgeist'
  spec.metadata['changelog_uri']         = 'https://github.com/LegionIO/lex-cognitive-zeitgeist/blob/master/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/LegionIO/lex-cognitive-zeitgeist/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true)
  end

  spec.require_paths = ['lib']
end
