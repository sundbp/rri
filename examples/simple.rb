# example of just setting up an engine, adding two numbers in R and retrieving the result

$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rri'

engine = Rri::Engine.new
result = engine.simple_eval("1.23 + 4.56")
puts "Result is: #{result} (which is of type #{result.class})"
engine.simple_assign("x", result)
result = engine.eval_and_convert("x")
puts "Result is: #{result} (which is of type #{result.class})"
engine.close
