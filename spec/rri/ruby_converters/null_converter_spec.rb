require 'spec_helper'
require 'rri'
require 'rri/ruby_converters/null_converter'

describe Rri::RubyConverters::NullConverter do
  it "should correctly convert NULL" do
    value = nil
    rexp = REXPNull.new
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
