# example of producing a pdf from an R plot

$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'rri'

engine = Rri::Engine.new

filename = "plot_from_r.pdf"
begin
  engine.simple_eval("data(iris)")
  engine.simple_eval("pdf('#{filename}')")
  engine.simple_eval("print(stripchart(iris[, 1:4], method = 'stack', pch = 16, cex = 0.4, offset = 0.6))")
  engine.simple_eval("dev.off()")
rescue => e
  puts "Caught exception: " + e
end

puts "Checkout plot generated in file: #{filename}"
