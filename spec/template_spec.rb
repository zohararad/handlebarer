require 'spec_helper'
require 'fileutils'

describe Handlebarer::Template do

  before :all do
    d = Rails.root.join('tmp','cache','assets')
    FileUtils.rm_r d if Dir.exists? d
  end

  def template(source, file)
    Handlebarer::Template.new(file){source}
  end

  it 'should have default mime type' do
    Handlebarer::Template.default_mime_type.should == 'application/javascript'
  end

  it 'should be served' do
    assets.should serve 'sample.js'
    asset_for('sample.js').body.should include "Yap, it works"
  end

  it 'should work fine with JST' do
    context = V8::Context.new
    context.eval %{
      #{asset_for('application.js').to_s}
      html = JST['sample']({"name": "Zohar"})
    }
    context.eval('html').gsub(/[\n\r\t]+/,'').should include "<title>Hello, Zohar :)</title>"
  end

end
