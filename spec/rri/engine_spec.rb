require 'spec_helper'
require 'rri'

describe Rri::Engine do
  
  it "should instantiate passing no args to .new" do
    engine = Rri::Engine.new
    engine.should_not be_nil
    engine.close
  end
  
  it "should instantiate passing options to .new" do
    engine = Rri::Engine.new(:r_arguments => ["--save"], :run_repl => false)
    engine.should_not be_nil    
    engine.close
  end
  
end
