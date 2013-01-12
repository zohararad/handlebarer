module Handlebarer
  # Handlebars template engine Javascript source code
  module Source

    # Handlebars source code
    def self.handlebars
      IO.read handlebars_path
    end

    # Handlebars source code path
    def self.handlebars_path
      File.expand_path("../../../vendor/assets/javascripts/handlebars/handlebars-1.0.rc.1.js", __FILE__)
    end

    # Handlebars runtime source code
    def self.runtime
      IO.read runtime_path
    end

    # Handlebars runtime source code path
    def self.runtime_path
      File.expand_path("../../../vendor/assets/javascripts/handlebars/handlebars.runtime-1.0.rc.1.js", __FILE__)
    end

  end
end