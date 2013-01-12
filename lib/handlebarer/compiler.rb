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
    # @param [String] controller_name name of Rails controller that's rendering the template
    # @param [Hash] vars controller instance variables passed to the template
    # @return [String] HTML output of compiled Handlerbars template
    def render(template, controller_name, vars = {})
      v8_context do |context|
        #context.eval(Handlebarer.configuration.includes.join("\n"))
        #combo = (template_mixins(controller_name) << template).join("\n").to_json
        #context.eval("var fn = jade.compile(#{combo})")
        #context.eval("fn(#{vars.to_jade.to_json})")
      end
    end

  end
end