require 'spec_helper'
require 'rri'
require 'rri/ruby_converters/integer_converter'

describe Rri::RubyConverters::IntegerConverter do
  it "should correctly convert an integer" do
    value = 1234
    rexp = REXPInteger.new(value)
    success, obj = subject.convert(rexp)
    success.should be_true
    obj.should == value
  end

  it "should correctly fail for non integers" do
    value = 1.23
    rexp = REXPDouble.new(value)
    success, obj = subject.convert(rexp)
    success.should be_false
  end
end
