# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'respoke/version'

Gem::Specification.new do |spec|
  spec.name          = 'respoke'
  spec.version       = Respoke::VERSION
  spec.date          = Time.now.strftime('%Y-%m-%d')
  spec.authors       = ['Matthew Turney']
  spec.email         = ['mturney@respoke.io']
  spec.summary       = %q{Wrapper library for the Respoke API.}
  spec.homepage      = 'https://respoke.io'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'faraday_middleware', '~> 0.9'
  spec.add_dependency 'hashie', '~> 3.3.2'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'ruby-lint'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'timecop'
end
