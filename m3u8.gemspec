# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'm3u8/version'

Gem::Specification.new do |spec|
  spec.name          = "m3u8"
  spec.version       = M3u8::VERSION
  spec.authors       = ["Seth Deckard"]
  spec.email         = ["seth@deckard.me"]
  spec.summary       = %q{Generates m3u8 playlists for HTTP Live Streaming.}
  spec.description   = %q{Generates m3u8 playlists for HTTP Live Streaming.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", ">= 2.11"
end
