# example of just setting up an engine, adding two numbers in R and retrieving the result

$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rri'

engine = Rri::Engine.new

# low level interface
result = engine.simple_eval("1.23 + 4.56")
puts "Result is: #{result} (which is of type #{result.class})"
engine.simple_assign(:x, result)

# higher level interface including conversions
result = engine.eval_and_convert("y <- x + 1")
result = engine.get_and_convert(:y)
puts "Result is: #{result} (which is of type #{result.class})"

# close the engine
engine.close
