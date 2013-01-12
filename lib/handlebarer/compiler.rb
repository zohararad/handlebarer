require 'v8'

module Handlebarer
  class Compiler

    # Handlerbars template engine Javascript source code used to compile templates in ExecJS
    # @return [String] Handlerbars source code
    def source
      @source ||= Handlebarer::Source::handlebars
    end

    # V8 context with Handlerbars code compiled
    # @yield [context] V8::Context compiled Handlerbars source code in V8 context
    def v8_context
      V8::C::Locker() do
        context = V8::Context.new
        context.eval(source)
        yield context
      end
    end

    # Handlerbars Javascript engine version
    # @return [String] version of Handlerbars javascript engine installed in `vendor/assets/javascripts`
    def handlebars_version
      v8_context do |context|
        context.eval("Handlebars.VERSION")
      end
    end

    # Compile a Handlerbars template for client-side use with JST
    # @param [String, File] template Handlerbars template file or text to compile
    # @return [String] Handlerbars template compiled into Javascript and wrapped inside an anonymous function for JST
    def compile(template)
      v8_context do |context|
        template = template.read if template.respond_to?(:read)
        compiled_handlebars = context.eval("Handlebars.precompile(#{template.to_json})")
        "Handlebars.template(#{compiled_handlebars});"
      end
    end

    # Compile and evaluate a Handlerbars template for server-side rendering
    # @param [String] template Handlerbars template text to render
    # @param [Hash] vars controller instance variables passed to the template
    # @return [String] HTML output of compiled Handlerbars template
    def render(template, vars = {})
      v8_context do |context|
        unless Handlebarer.configuration.nil?
          helpers = handlebars_helpers
          context.eval(helpers.join("\n")) if helpers.any?
        end
        context.eval("var fn = Handlebars.compile(#{template.to_json})")
        context.eval("fn(#{vars.to_hbs.to_json})")
      end
    end

    # Handlebars helpers
    # @return [Array<String>] array of Handlebars helpers to use with a Handlebars template rendered by a Rails controller
    def handlebars_helpers
      helpers = []
      unless Handlebarer.configuration.helpers_path.nil?
        Dir["#{Handlebarer.configuration.helpers_path}/*.js"].each do |f|
          helpers << IO.read(f)
        end
      end
      helpers
    end

  end
end