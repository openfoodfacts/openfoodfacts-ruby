# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openfoodfacts/version'

Gem::Specification.new do |spec|
  spec.name          = 'openfoodfacts'
  spec.version       = Openfoodfacts::VERSION
  spec.authors       = ["Nicolas Leger"]
  spec.email         = ["nicolas.leger@nleger.com"]

  spec.summary       = "OpenFoodFacts API Wrapper"
  spec.description   = "OpenFoodFacts API Wrapper, the open database about food."
  spec.homepage      = "https://github.com/openfoodfacts/openfoodfacts-ruby"
  spec.license       = "MIT"

  spec.files         = Dir['Rakefile', '{features,lib,test}/**/*', 'README*', 'LICENSE*']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0' # Needed for keyword arguments
  
  spec.add_runtime_dependency 'hashie', '~> 3.4'
  spec.add_runtime_dependency 'nokogiri', '~> 1.6'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'minitest', '~> 5.8'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 1.22'
end
