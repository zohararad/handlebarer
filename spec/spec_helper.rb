ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'bundler/setup'

require File.expand_path('../../spec/dummy/config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'rails/test_help'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'handlebarer'

Rails.backtrace_cleaner.remove_silencers!

RSpec.configure do |config|
  require 'rspec/mocks'
  require 'rspec/expectations'
  config.include RSpec::Matchers
  config.mock_with :rspec

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
