require 'spec_helper'
require 'rri'
require 'rri/r_converters/integer_converter'

describe Rri::RConverters::IntegerConverter do
  it "should correctly convert an Integer" do
    ruby_input = 1234
    success, value = subject.convert(ruby_input)
    success.should be_true
    value.class.should == Java::OrgRosudaREngine::REXPInteger
    value.asDouble.should == ruby_input
  end

  it "should correctly fail for non Integers" do
    ruby_input = 1.23
    success, value = subject.convert(ruby_input)
    success.should be_false
  end
end
