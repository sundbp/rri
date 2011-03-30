require 'rri/rexp'

module Rri
  module RConverters
    
    # Converter for ruby Floats
    #
    # Convert ruby Floats to double in R
    class FloatConverter
      
      # Convert ruby object to R format
      # 
      # If the ruby object is a Float, converts it into an R double
      # 
      # @param obj object to convert
      # @return [Array] an array of size 2 where first element is a boolean indicating succes,
      #   and the second element is the converted object if conversion successful    
      def convert(obj)
        if obj.kind_of? Float
          [true, REXPDouble.new(obj)]
        else
          [false, nil]
        end
      end
    end
    
  end
end