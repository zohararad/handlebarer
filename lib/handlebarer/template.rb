require 'tilt/template'

module Handlebarer

  # Handlebarer Tilt template for use with JST
  class Template < Tilt::Template
    self.default_mime_type = 'application/javascript'

    # Ensure V8 is available when engine is initialized
    def self.engine_initialized?
      defined? ::V8
    end

    # Require 'execjs' when initializing engine
    def initialize_engine
      require_template_library 'v8'
    end

    def prepare
    end

    # Evaluate the template. Compiles the template for JST
    # @return [String] JST-compliant compiled version of the Handlebars template being rendered
    def evaluate(scope, locals, &block)
      c = Handlebarer::Compiler.new
      compiled_handlebars = c.compile(data)
      %{
        Handlebars.template(#{compiled_handlebars});
      }
    end

  end
end
