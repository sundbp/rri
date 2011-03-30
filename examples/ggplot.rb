# example of drawing a density with ggplot2

$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rri'

# Ruby Gaussian Random Number Generator
# Author: Glenn
# http://webhost101.net/rails/typo/articles/2007/07/31/ruby-gaussian-random-number-generator

def gaussian_rand 
   u1 = u2 = w = g1 = g2 = 0  # declare
   begin
     u1 = 2 * rand - 1
     u2 = 2 * rand - 1
     w = u1 * u1 + u2 * u2
   end while w >= 1
   
   w = Math::sqrt( ( -2 * Math::log(w)) / w )
   g2 = u1 * w;
   g1 = u2 * w;
   # g1 is returned  
end

random_numbers = []
1000.times { random_numbers << gaussian_rand }

# use the std out callback object to get some printouts from R, good for debugging.
engine = Rri::Engine.new(:callback_object => Rri::CallbackObjects::REngineStdOutput.new)

filename = "ggplot.pdf"
begin
  engine.simple_eval("library(ggplot2)")
  engine.convert_and_assign(random_numbers, :y)
  engine.simple_eval("df <- data.frame(y)")
  engine.simple_eval("pdf('#{filename}')")
  engine.simple_eval("print(qplot(y, data=df, geom='histogram', binwidth=0.1))")
  engine.simple_eval("dev.off()")
rescue => e
  puts "Caught exception: " + e
end

puts "Checkout plot generated in file: #{filename}"
