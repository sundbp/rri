require 'spec_helper'
require 'rri'

describe Rri::Engine do

  before(:each) do
    @engine = Rri::Engine.new
    Rri::Engine.clear_r_converters
  end
  
  describe "instantiation" do
    
    it "should instantiate passing no args to .new" do
      @engine.should_not be_nil
    end
    
    it "should instantiate passing options to .new" do
      @engine = Rri::Engine.new(:r_arguments => ["--save"], :run_repl => false)
      @engine.should_not be_nil    
    end
    
  end

  describe "converstion to R objects" do
    describe "at the instance level" do
      
      it "should be able to add an instance level converter" do
        converter = mock('converter')
        @engine.add_r_converter(converter)
        @engine.r_converters.size.should == 1
        @engine.r_converters[0] == converter
      end
      
      it "should be able to add several instance level converters and return them in reverse order" do
        converter1 = mock('converter')
        converter2 = mock('converter')
        @engine.add_r_converter(converter1)
        @engine.add_r_converter(converter2)
        @engine.r_converters.size.should == 2
        @engine.r_converters[0] == converter2
        @engine.r_converters[1] == converter1
      end
      
      it "should correctly convert to R objects using instance level custom converters" do
        ruby_value = 123
        converter = double('converter')
        converter.should_receive(:convert).and_return([true, ruby_value.to_s])
        @engine.add_r_converter(converter)
        rexp = @engine.convert_to_r_object(ruby_value)
        rexp.should == ruby_value.to_s
      end
      
    end
    
    describe "at the class level" do
      
      it "should be able to add a class level converter" do
        converter = mock('converter')
        Rri::Engine.add_r_converter(converter)
        Rri::Engine.r_converters.size.should == 1
        Rri::Engine.r_converters[0] == converter
      end
      
      it "should be able to add several class level converters and return them in reverse order" do
        converter1 = mock('converter')
        converter2 = mock('converter')
        Rri::Engine.add_r_converter(converter1)
        Rri::Engine.add_r_converter(converter2)
        Rri::Engine.r_converters.size.should == 2
        Rri::Engine.r_converters[0] == converter2
        Rri::Engine.r_converters[1] == converter1
      end
      
      it "should correctly convert to R objects using class level custom converters" do
        ruby_value = 123
        converter = double('converter')
        converter.should_receive(:convert).and_return([true, ruby_value.to_s])
        Rri::Engine.add_r_converter(converter)
        rexp = @engine.convert_to_r_object(ruby_value)
        rexp.should == ruby_value.to_s
      end
    end
    
    describe "using defaults" do
      it "should correctly convert to R objects using default converters" do
        ruby_value = 123
        rexp = @engine.convert_to_r_object(ruby_value)
        rexp.class.should == Java::OrgRosudaREngine::REXPInteger
        rexp.asInteger.should == ruby_value
      end
    end
    
    it "should raise if no conversion available when converting ruby object to R object" do
      ruby_value = @engine
      expect { @engine.convert_to_r_object(ruby_value) }.to raise_error(Rri::RriException)
    end    
  end

end
