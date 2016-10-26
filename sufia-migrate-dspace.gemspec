# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sufia/migrate-dspace/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Aaron Collier"]
  gem.email         = ["acollier@calstate.edu"]
  gem.description   = %q{Rake tast to import data from DSpace exported AIP packages into Sufia.}
  gem.summary       = %q{Rake tast to import data from DSpace exported AIP packages into Sufia.}
  gem.homepage      = "https://github.com/scholarworks/sufia-migrate-dspace"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sufia-migrate-dspace"
  gem.require_paths = ["lib"]
  gem.version       = Sufia::MigrateDspace::VERSION
  gem.license       = 'Apache 2.0'

end