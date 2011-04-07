require 'spec_helper'
require 'rri'
require 'rri/ruby_converters/double_converter'

describe Rri::RubyConverters::DoubleConverter do
  it "should correctly convert a double" do
    value = 1.234
    rexp = REXPDouble.new(value)
    success, obj = subject.convert(rexp)
    success.should be_true
    obj.should == value
  end

  it "should correctly fail for non-doubles" do
    value = 123
    rexp = REXPInteger.new(value)
    success, obj = subject.convert(rexp)
    success.should be_false
  end
end
