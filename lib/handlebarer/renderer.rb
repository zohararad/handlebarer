module Handlebarer
  # Server side Jade templates renderer
  module Renderer

    # Convert Handlebars template to HTML output for rendering as a Rails view
    # @param [String] template_text Handlebars template text to convert
    # @param [String] controller_name name of Rails controller rendering the view
    # @param [Hash] vars controller instance variables passed to the template
    # @return [String] HTML output of evaluated template
    # @see Handlebarer::Compiler#render
    def self.convert_template(template_text, vars = {})
      compiler = Handlebarer::Compiler.new
      compiler.render(template_text, vars)
    end

    # Prepare controller instance variables for the template and execute template conversion.
    # Called as an ActionView::Template registered template
    # @param [ActionView::Template] template currently rendered ActionView::Template instance
    # @see Handlebarer::Renderer#convert_template
    def self.call(template)
      #template.source.gsub!(/\#\{([^\}]+)\}/,"\\\#{\\1}") # escape Handlebars' #{somevariable} syntax
      %{
        template_source = %{#{template.source}}
        variable_names = controller.instance_variable_names
        variable_names -= %w[@template]
        if controller.respond_to?(:protected_instance_variables)
          variable_names -= controller.protected_instance_variables
        end

        variables = {}
        variable_names.each do |name|
          next if name.include? '@_'
          variables[name.sub(/^@/, "")] = controller.instance_variable_get(name)
        end
        Handlebarer::Renderer.convert_template(template_source, variables.merge(local_assigns))
      }
    end

  end
end