# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openfoodfacts/version'

Gem::Specification.new do |spec|
  spec.name          = 'openfoodfacts'
  spec.version       = Openfoodfacts::VERSION
  spec.authors       = ["Nicolas Leger"]
  spec.email         = ["nicolas.leger@nleger.com"]

  spec.summary       = "Open Food Facts API Wrapper"
  spec.description   = "Open Food Facts API Wrapper, the open database about food."
  spec.homepage      = "https://github.com/openfoodfacts/openfoodfacts-ruby"
  spec.license       = "MIT"

  spec.files         = Dir['Rakefile', '{features,lib,test}/**/*', 'README*', 'LICENSE*']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1' # Needed for keyword arguments and nokogiri >= 1.7.0

  spec.add_runtime_dependency 'hashie', '~> 3.4'
  spec.add_runtime_dependency 'nokogiri', '~> 1.7'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'minitest', '~> 5.10'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.3'
end
