# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hive/toolbelt/version'

Gem::Specification.new do |spec|
  spec.name          = "hive-toolbelt"
  spec.version       = Hive::Toolbelt::VERSION
  spec.authors       = ["Wei Lu"]
  spec.email         = ["luwei.here@gmail.com"]
  spec.summary       = %q{Command Line Interface for the Hive wallet}
  spec.description   = %q{All you need for developing Hive apps.}
  spec.homepage      = "https://github.com/hivewallet/toolbelt"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "debugger"
end
