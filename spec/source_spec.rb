require 'spec_helper'

describe Handlebarer::Source do
  it "should contain handlebars asset" do
    File.exist?(Handlebarer::Source::handlebars_path).should be_true
  end

  it "should be able to read handlebars source" do
    IO.read(Handlebarer::Source::handlebars_path).should_not be_empty
  end

end