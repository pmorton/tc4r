# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tc4r/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Morton"]
  gem.email         = ["pmorton@biaprotect.com"]
  gem.description   = %q{Teamcity Client for Ruby}
  gem.summary       = %q{A Teamcity Client for Ruby}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tc4r"
  gem.require_paths = ["lib"]
  gem.bindir        = ['bin']
  gem.executables = ['tc', 'tc-setup']
  gem.version       = Tc4r::VERSION
  gem.add_dependency 'commander', '~> 4.1.3'
  gem.add_dependency "nestful", '~> 0.0.8'
  gem.add_dependency 'terminal-table', '~> 1.4'
  gem.add_dependency 'activemodel', '~> 3.2.13'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'fakeweb'
  gem.add_development_dependency 'fakeweb-matcher'
  gem.add_development_dependency 'simplecov'
end
