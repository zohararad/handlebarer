# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'handlebarer/version'

Gem::Specification.new do |gem|
  gem.name          = "handlebarer"
  gem.version       = Handlebarer::VERSION
  gem.authors       = ["Zohar Arad"]
  gem.email         = ["zohar@zohararad.com"]
  gem.description   = %q{JST and Rails views compiler for Handlebars templates}
  gem.summary       = %q{Share your Handlebars views between client and server, eliminate code duplication and make your single-page app SEO friendly}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'tilt'
  gem.add_dependency 'sprockets'
  gem.add_dependency 'therubyracer'
  gem.add_dependency 'libv8', '3.11.8'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'rails', '>= 3.1'
end
