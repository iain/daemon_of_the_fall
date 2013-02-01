# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daemon_of_the_fall/version'

Gem::Specification.new do |gem|
  gem.name          = "daemon_of_the_fall"
  gem.version       = DaemonOfTheFall::VERSION
  gem.authors       = ["iain"]
  gem.email         = ["iain@iain.nl"]
  gem.description   = %q{Start, restart and stop multiple instances of daemons that don't support that.}
  gem.summary       = %q{Start, restart and stop multiple instances of daemons that don't support that.}
  gem.homepage      = "https://github.com/iain/daemon_of_the_fall"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
end
