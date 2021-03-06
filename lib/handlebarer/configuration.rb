module Handlebarer
  class << self
    attr_accessor :configuration
  end

  # Configure Handlebarer
  # @yield [config] Handlebarer::Configuration instance
  # @example
  #     Handlebarer.configure do |config|
  #       config.helpers_path = Rails.root.join('app','assets','javascripts','helpers')
  #       config.views_path = Rails.root.join('app','assets','javascripts','views')
  #     end
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  # Jader configuration class
  class Configuration
    attr_accessor :helpers_path, :views_path

    # Initialize Jader::Configuration class with default values
    def initialize
      @helpers_path = nil
      @views_path = nil
    end
  end
end