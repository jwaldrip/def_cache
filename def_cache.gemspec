# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'def_cache/version'

Gem::Specification.new do |spec|
  spec.name          = "def_cache"
  spec.version       = DefCache::VERSION
  spec.authors       = ["Jason Waldrip"]
  spec.email         = ["jason@waldrip.net"]
  spec.description   = 'An agnostic ActiveSupport::Cache helper to enable easy caching of methods inside your classes.'
  spec.summary       = 'An agnostic ActiveSupport::Cache helper to enable easy caching of methods inside your classes.'
  spec.homepage      = "https://github.com/jwaldrip/funky_cache"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", '>= 3.2'

  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

end
