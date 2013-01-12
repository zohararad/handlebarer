require 'handlebarer/source'
require 'handlebarer/compiler'
require 'handlebarer/template'
require 'handlebarer/engine' if defined?(::Rails)
#require 'handlebarer/renderer'
#require 'handlebarer/configuration'
#require 'handlebarer/serialize'

#ActionView::Template.register_template_handler :handlebars, Jader::Renderer
#ActionView::Template.register_template_handler 'jst.handlebars', Jader::Renderer