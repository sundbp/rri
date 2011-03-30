require 'spec_helper'
require 'rri'
require 'rri/r_converters/array_converter'

describe Rri::RConverters::ArrayConverter do
  it "should correctly convert an Array of all Floats" do
    ruby_value = [1.2, 3.4, -5.6]
    success, value = subject.convert(ruby_value)
    success.should be_true
    value.class.should == Java::OrgRosudaREngine::REXPDouble
    value.length.should == ruby_value.size
    value.asDoubles.to_a.should == ruby_value
  end
  
  it "should correctly convert an Array of all Integers" do
    ruby_value = [1, 2, -4, 5]
    success, value = subject.convert(ruby_value)
    success.should be_true
    value.class.should == Java::OrgRosudaREngine::REXPInteger
    value.length.should == ruby_value.size
    value.asIntegers.to_a.should == ruby_value    
  end
  
  it "should correctly convert an Array of all Strings" do
    ruby_value = ["foo", "bar", "baz"]
    success, value = subject.convert(ruby_value)
    success.should be_true
    value.class.should == Java::OrgRosudaREngine::REXPString
    value.length.should == ruby_value.size
    value.asStrings.to_a.should == ruby_value    
  end
  
  it "should fail to convert a non Array" do
    success, value = subject.convert({:a =>1})
    success.should be_false
    success, value = subject.convert(1)
    success.should be_false
    success, value = subject.convert(1.2)
    success.should be_false
  end
  
  it "should fail to convert an Array with elements of mixed types" do
    success, value = subject.convert([1, 1.2, "foo"])
    success.should be_false
    success, value = subject.convert([1, 1.2])
    success.should be_false
  end
  
  it "should fail to convert an Array with elements of same but unsupported types" do
    class Foo
    end
    success, value = subject.convert([Foo.new, Foo.new])
    success.should be_false
  end

end
