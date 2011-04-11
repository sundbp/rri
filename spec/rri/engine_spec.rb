require 'spec_helper'
require 'rri'

describe Rri::Engine do

  # describe "class level singleton engine" do
  #   # Note: we do the full test in one go to not recreate the engine too many times
  #   # See note below in before(:all) for more details.
  #   it "should create the engine, use engine and close engine" do
  #     Rri::Engine.create_engine
  #     engine1 = nil
  #     result = Rri::Engine.use_engine do |engine|
  #       engine1 = engine
  #       ruby_value = 1.23
  #       engine.convert_and_assign(ruby_value, :x)
  #       rexp = engine.get("x", nil, true)
  #       rexp.class.should == REXPDouble
  #       rexp.asDouble.should == ruby_value
  #       ruby_value
  #     end
  #     result.should == 1.23
  #     
  #     Rri::Engine.use_engine do |engine|
  #       engine1.should == engine
  #     end
  #     
  #     engine1.should == Rri::Engine.engine
  #     
  #     #expect { Rri::Engine.create_engine}.to raise_error(Rri::RriException)
  #     
  #     # Rri::Engine.close_engine
  #     # Rri::Engine.engine_is_created?.should be_false
  #     # 
  #     # expect { Rri::Engine.use_engine {|e| "foo" } }.to raise_error(Rri::RriException)
  #   end
  # end

  before(:all) do
    # Note: we can't create a new engine for each test because of bug
    # in JRI/R. After 12 recreations in same process something in the
    # C layer gets stuck, not sure if the JRI JNI code or the R lib.
    # That's true even if we properly close and dispose of the engines.
    # That wont be much of a limit in practice, just not ideal for testing.
    Rri::Engine.create_engine
  end

  before(:each) do
    # since we're not recreating engine each time we need to clear caches
    # between runs
    Rri::Engine.clear_r_converters
    Rri::Engine.clear_ruby_converters
    Rri::Engine.engine.clear_r_converters
    Rri::Engine.engine.clear_ruby_converters
    Rri::Engine.engine.clear_all_eval_expression_listeners
  end
  
  after(:all) do
    Rri::Engine.close_engine
  end
  
  describe "instantiation" do
    
    it "should instantiate passing no args to .new" do
      Rri::Engine.engine.should_not be_nil
      Rri::Engine.engine_is_created?.should be_true
    end
    
    it "should do the right thing for other creation and close scenarios" do
      # Note: we do several tests in one go here to not recreate the engine too
      # many times. See note above in before(:all) for more details.
      Rri::Engine.engine_is_created?.should be_true
      Rri::Engine.close_engine
      Rri::Engine.engine_is_created?.should be_false        
      expect { Rri::Engine.use_engine {|e| "foo" } }.to raise_error(Rri::RriException)
      
      e = Rri::Engine.new(:r_arguments => ["--save"], :run_repl => false)
      e.should_not be_nil
      e.close
      
      # make sure we have an engine again for the other tests
      Rri::Engine.create_engine
    end
    
    it "should not allow more than 1 call to Engine.create_engine" do
      expect { Rri::Engine.create_engine}.to raise_error(Rri::RriException)
    end
    
  end
  
  describe "when converting ruby objects to R objects" do
    
    describe "at the instance level" do
      
      it "should be able to add an instance level R converter" do
        converter = mock('converter')
        Rri::Engine.use_engine do |engine|
          engine.add_r_converter(converter)
          engine.r_converters.size.should == 1
          engine.r_converters[0] == converter
        end
      end
      
      it "should be able to add several instance level R converters and return them in reverse order" do
        converter1 = mock('converter')
        converter2 = mock('converter')
        Rri::Engine.use_engine do |engine|
          engine.add_r_converter(converter1)
          engine.add_r_converter(converter2)
          engine.r_converters.size.should == 2
          engine.r_converters[0] == converter2
          engine.r_converters[1] == converter1
        end
      end
      
      it "should correctly convert to R objects using instance level custom converters" do
        ruby_value = 123
        converter = double('converter')
        converter.should_receive(:convert).and_return([true, ruby_value.to_s])
        Rri::Engine.use_engine do |engine|
          engine.add_r_converter(converter)
          success, rexp = engine.convert_to_r_object(ruby_value)
          success.should be_true
          rexp.should == ruby_value.to_s
        end
      end
      
      it "should be able to remove an R converter" do
        converter = mock('converter')
        Rri::Engine.use_engine do |engine|
          engine.add_r_converter(converter)
          engine.r_converters.size.should == 1
          engine.remove_r_converter(converter)
          engine.r_converters.size.should == 0
        end        
      end
      
    end
    
    describe "at the class level" do
      
      it "should be able to add a class level R converter" do
        converter = mock('converter')
        Rri::Engine.add_r_converter(converter)
        Rri::Engine.r_converters.size.should == 1
        Rri::Engine.r_converters[0] == converter
      end
      
      it "should be able to add several class level R converters and return them in reverse order" do
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
        success, rexp = Rri::Engine.engine.convert_to_r_object(ruby_value)
        success.should be_true
        rexp.should == ruby_value.to_s
      end
    end
    
    it "should correctly convert to R objects using default converters" do
      ruby_value = 123
      success, rexp = Rri::Engine.engine.convert_to_r_object(ruby_value)
      success.should be_true
      rexp.class.should == REXPInteger
      rexp.asInteger.should == ruby_value
    end
    
    it "should return failure if no conversion available when converting ruby object to R object" do
      ruby_value = Rri::Engine.engine
      success, rexp = Rri::Engine.engine.convert_to_r_object(ruby_value)
      success.should be_false
      rexp.should == Rri::Engine.engine
    end
  end
  
  describe "when converting R objects to ruby objects" do
    
    describe "at the instance level" do
      
      it "should be able to add an instance level ruby converter" do
        converter = mock('converter')
        Rri::Engine.use_engine do |engine|
          engine.add_ruby_converter(converter)
          engine.ruby_converters.size.should == 1
          engine.ruby_converters[0] == converter
        end
      end
      
        it "should be able to add several instance level converters and return them in reverse order" do
          converter1 = mock('converter')
          converter2 = mock('converter')
          Rri::Engine.use_engine do |engine|
            engine.add_ruby_converter(converter1)
            engine.add_ruby_converter(converter2)
            engine.ruby_converters.size.should == 2
            engine.ruby_converters[0] == converter2
            engine.ruby_converters[1] == converter1
          end
        end
        
      it "should correctly convert to R objects using instance level custom converters" do
        value = 123
        rexp = REXPInteger.new(value)
        converter = double('converter')
        converter.should_receive(:convert).and_return([true, value])
        Rri::Engine.use_engine do |engine|
          engine.add_ruby_converter(converter)
          success, obj = engine.convert_to_ruby_object(rexp)
          success.should be_true
          obj.should == value
        end
      end
    end
    
    describe "at the class level" do
      
      it "should be able to add a class level ruby converter" do
        converter = mock('converter')
        Rri::Engine.add_ruby_converter(converter)
        Rri::Engine.ruby_converters.size.should == 1
        Rri::Engine.ruby_converters[0] == converter
      end
      
      it "should be able to add several instance level ruby converters and return them in reverse order" do
        converter1 = mock('converter')
        converter2 = mock('converter')
        Rri::Engine.add_ruby_converter(converter1)
        Rri::Engine.add_ruby_converter(converter2)
        Rri::Engine.ruby_converters.size.should == 2
        Rri::Engine.ruby_converters[0] == converter2
        Rri::Engine.ruby_converters[1] == converter1
      end
      
      it "should correctly convert to ruby objects using class level custom converters" do
        value = 123
        rexp = REXPInteger.new(value)
        converter = double('converter')
        converter.should_receive(:convert).and_return([true, value])
        Rri::Engine.add_ruby_converter(converter)
        success, obj = Rri::Engine.engine.convert_to_ruby_object(rexp)
        success.should be_true
        obj.should == value
      end
    end
    
    it "should correctly convert to ruby objects using default converters" do
      value = 123
      rexp = REXPInteger.new(value)
      success, obj = Rri::Engine.engine.convert_to_ruby_object(rexp)
      success.should be_true
      obj.should == value
    end
    
    it "should return failure if no conversion available when converting ruby object to R object" do
      rexp = Rri::Engine.engine
      success, obj = Rri::Engine.engine.convert_to_ruby_object(rexp)
      success.should be_false
      obj.should == Rri::Engine.engine
    end
  end
  
  it "should correctly convert a ruby object and assign it to an R variable" do
    ruby_value = 1.23
    Rri::Engine.engine.convert_and_assign(ruby_value, :x)
    rexp = Rri::Engine.engine.get("x", nil, true)
    rexp.class.should == REXPDouble
    rexp.asDouble.should == ruby_value
  end
  
  it "should raise if it can't correctly convert a ruby object and assign it to an R variable" do
    expect { Rri::Engine.engine.convert_and_assign(Rri::Engine.engine, :x) }.to raise_error(Rri::RriException)
  end
  
  it "should correctly add and remove eval expression listeners given as Proc's" do
    Rri::Engine.use_engine do |engine|
      engine.eval_expression_listeners.size.should == 0
      listener = Proc.new {|msg| msg }
      engine.add_eval_expression_listener(listener)
      engine.eval_expression_listeners.size.should == 1
      engine.eval_expression_listeners[0] == listener
      engine.remove_eval_expression_listener(listener)
      engine.eval_expression_listeners.size.should == 0
    end
  end

  it "should correctly add eval expression listeners given as block" do
    Rri::Engine.use_engine do |engine|
      engine.eval_expression_listeners.size.should == 0
      engine.add_eval_expression_listener do |msg|
        msg
      end
      engine.eval_expression_listeners.size.should == 1
      engine.eval_expression_listeners[0].class.should == Proc
      engine.clear_all_eval_expression_listeners
      engine.eval_expression_listeners.size.should == 0
    end
  end

  it "should correctly call eval expression listeners" do
    result_block = nil
    result_proc = nil
    Rri::Engine.use_engine do |engine|
      engine.add_eval_expression_listener do |msg|
        result_block = msg
      end
      proc = Proc.new {|msg| result_proc = msg}
      engine.add_eval_expression_listener(proc)
    
      expr = "1 + 1"
      engine.simple_eval(expr)
      result_block.should == expr
      result_proc.should == expr
      expr = "1 + 2"
      engine.eval_and_convert(expr)
      result_block.should == expr
      result_proc.should == expr
    end
  end
  
  it "should return the last value of block when using use_engine" do
    ruby_value = 1.23
    result = Rri::Engine.use_engine do |engine|
      engine.convert_and_assign(ruby_value, :x)
      rexp = engine.get("x", nil, true)
      rexp.class.should == REXPDouble
      rexp.asDouble.should == ruby_value
      rexp.asDouble
    end
    result.should == 1.23
  end
  
  it "should pass the same engine to Engine.use_engine as Engine.engine" do
    Rri::Engine.use_engine do |engine|
      Rri::Engine.engine.should == engine
    end
  end
  
  it "should be able to pass r_converters to use_engine" do
    Rri::Engine.engine.r_converters.size.should == 0    
    converter = mock('converter')
    Rri::Engine.use_engine(:r_converters => [converter]) do |engine|
      engine.r_converters.size.should == 1
      engine.remove_r_converter(converter)
    end
    Rri::Engine.engine.r_converters.size.should == 0
  end
  
  it "should handle simple_get" do
    ruby_value = 1.23
    result = Rri::Engine.use_engine do |engine|
      engine.convert_and_assign(ruby_value, :x)
      rexp = engine.simple_get(:x)
      rexp.class.should == REXPReference
      rexp.asDouble.should == ruby_value
    end
  end
  
  it "should handle #get_and_convert" do
    ruby_value = 1.23
    result = Rri::Engine.use_engine do |engine|
      engine.convert_and_assign(ruby_value, :x)
      engine.get_and_convert(:x)
    end
    result.should == ruby_value
  end
  
end
