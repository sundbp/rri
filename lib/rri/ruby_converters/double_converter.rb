require 'rri/rexp'

module Rri
  module RubyConverters
    
    # Converter for R Integers
    #
    # Convert R double to ruby Fixnum
    class DoubleConverter
      
      # Convert R object to ruby format
      # 
      # If the R object is a double, converts it into a ruby Float
      # 
      # @param [REXP] rexp rexp to convert
      # @return [Array] an array of size 2 where first element is a boolean indicating succes,
      #   and the second element is the converted object if conversion successful    
      def convert(rexp)
        if rexp.kind_of?(REXP) and rexp.isNumeric and !rexp.isInteger and !rexp.isComplex and rexp.length == 1
          [true, rexp.asDouble]
        else
          [false, nil]
        end
      end
    end
    
  end
end
