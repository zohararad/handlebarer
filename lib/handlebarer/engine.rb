require 'sprockets'
require 'sprockets/engines'

module Handlebarer
  class Engine < Rails::Engine
    initializer 'handlebarer.configure_rails_initialization', :before => 'sprockets.environment', :group => :all do |app|
      next unless app.config.assets.enabled
      Sprockets.register_engine '.hbs', ::Handlebarer::Template
      Sprockets.register_engine '.handlebars', ::Handlebarer::Template
    end

    initializer 'handlebarer.prepend_views_path', :after => :add_view_paths do |app|
      next if Handlebarer::configuration.nil? or Handlebarer::configuration.views_path.nil?
      ActionController::Base.class_eval do
        before_filter do |controller|
          prepend_view_path Handlebarer::configuration.views_path
        end
      end
    end

  end
end
