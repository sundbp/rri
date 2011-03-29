require 'spec_helper'
require 'rri'
require 'rri/r_converters/string_converter'

describe Rri::RConverters::StringConverter do
  it "should correctly convert a String" do
    ruby_input = "foobar"
    success, value = subject.convert(ruby_input)
    success.should be_true
    value.class.should == Java::OrgRosudaREngine::REXPString
    value.asString.should == ruby_input
  end

  it "should correctly fail for non Strings" do
    ruby_input = 1.23
    success, value = subject.convert(ruby_input)
    success.should be_false
  end
end
