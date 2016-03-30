# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'm3u8/version'

Gem::Specification.new do |spec|
  spec.name          = 'm3u8'
  spec.version       = M3u8::VERSION
  spec.authors       = ['Seth Deckard']
  spec.email         = ['seth@deckard.me']
  spec.summary       = %q{Generate and parse m3u8 playlists for HTTP Live Streaming (HLS).}
  spec.description   = %q{Generate and parse m3u8 playlists for HTTP Live Streaming (HLS).}
  spec.homepage      = 'https://github.com/sethdeckard/m3u8'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'simplecov'
end
