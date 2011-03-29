require 'spec_helper'
require 'rri'
require 'rri/r_converters/float_converter'

describe Rri::RConverters::FloatConverter do
  it "should correctly convert a Float" do
    ruby_input = 1.2
    success, value = subject.convert(ruby_input)
    success.should be_true
    value.class.should == Java::OrgRosudaREngine::REXPDouble
    value.asDouble.should == ruby_input
  end

  it "should correctly fail for non Floats" do
    ruby_input = 1
    success, value = subject.convert(ruby_input)
    success.should be_false
  end
end
