require 'spec_helper'
require 'rri'
require 'rri/ruby_converters/string_converter'

describe Rri::RubyConverters::StringConverter do
  it "should correctly convert a string" do
    value = "foobar"
    rexp = REXPString.new(value)
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
