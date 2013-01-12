$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "handlebarer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |gem|
  gem.name        = "handlebarer"
  gem.version     = Handlebarer::VERSION
  gem.authors     = ["Zohar Arad"]
  gem.email       = ["zohar@zohararad.com"]
  gem.homepage    = "TODO"
  gem.summary     = "JST and Rails views compiler for Handlebars templates"
  gem.description = "Share your Handlebars views between client and server, eliminate code duplication and make your single-page app SEO friendly"

  gem.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'tilt'
  gem.add_dependency 'sprockets'
  gem.add_dependency 'therubyracer'
  gem.add_dependency 'libv8', '3.11.8'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'rails', '~> 3.2.11'
  gem.add_development_dependency 'sqlite3'
end
