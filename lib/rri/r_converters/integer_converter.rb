require 'rri/rexp'

module Rri
  module RConverters
    
    # Converter for ruby Integers
    #
    # Convert ruby Integer to integer in R
    class IntegerConverter
      
      # Convert ruby object to R format
      # 
      # If the ruby object is an Integer, converts it into an R integer
      # 
      # @param obj object to convert
      # @return [Array] an array of size 2 where first element is a boolean indicating succes,
      #   and the second element is the converted object if conversion successful    
      def convert(obj)
        if obj.kind_of? Integer
          [true, REXPInteger.new(obj)]
        else
          [false, nil]
        end
      end
    end
    
  end
end
