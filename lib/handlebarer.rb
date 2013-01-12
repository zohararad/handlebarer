require 'handlebarer/source'
require 'handlebarer/compiler'
require 'handlebarer/template'
require 'handlebarer/engine' if defined?(::Rails)
require 'handlebarer/renderer'
require 'handlebarer/serialize'
require 'handlebarer/configuration'

ActionView::Template.register_template_handler :handlebars, Handlebarer::Renderer
ActionView::Template.register_template_handler :hbs, Handlebarer::Renderer
ActionView::Template.register_template_handler 'jst.handlebars', Handlebarer::Renderer
ActionView::Template.register_template_handler 'jst.hbs', Handlebarer::Renderer