# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_service/version'

Gem::Specification.new do |spec|
  spec.name          = "active-service"
  spec.version       = ActiveService::VERSION
  spec.authors       = ["Martin Fernandez", "Andres Pache"]
  spec.email         = ["fmartin91@gmail.com", "apache90@gmail.com"]
  spec.summary       = %q{ Steroids for business modules. }
  spec.description   = %q{ Steroids for business modules. }
  spec.homepage      = "https://github.com/bilby91/active_service"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "grape"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency "json_expressions", "~> 0.8"
  spec.add_development_dependency "rubocop"
end
