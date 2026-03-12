lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'm3u8/version'

Gem::Specification.new do |spec|
  spec.name          = 'm3u8'
  spec.version       = M3u8::VERSION
  spec.authors       = ['Seth Deckard']
  spec.email         = ['seth@deckard.me']
  spec.summary       = 'Generate and parse m3u8 playlists for HTTP Live Streaming (HLS).'
  spec.description   = 'Generate and parse m3u8 playlists for HTTP Live Streaming (HLS).'
  spec.homepage      = 'https://github.com/sethdeckard/m3u8'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/sethdeckard/m3u8',
    'changelog_uri' => 'https://github.com/sethdeckard/m3u8/blob/master/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/sethdeckard/m3u8/issues'
  }

  spec.files         = `git ls-files -z`.split("\x0")
                                        .grep_v(/\A(CLAUDE|AGENTS)\.md\z/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.add_dependency 'bigdecimal'
  spec.require_paths = ['lib']

end
