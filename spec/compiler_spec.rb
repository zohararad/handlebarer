require 'spec_helper'

describe Handlebarer::Compiler do
  before :each do
    @compiler = Handlebarer::Compiler.new
  end

  it "should contain v8 context" do
    @compiler.v8_context do |context|
      context.eval("typeof Handlebars").should == 'object'
    end
  end

  it "should define Handlebars compiler version" do
    @compiler.handlebars_version.should == "1.0.rc.1"
  end

  it "should compile small thing" do
    @compiler.compile('<h1>Testing</h1>').should include '<h1>Testing</h1>'
  end

end