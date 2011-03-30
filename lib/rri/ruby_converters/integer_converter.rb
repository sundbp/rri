require 'rri/rexp'

module Rri
  module RubyConverters
    
    # Converter for R Integers
    #
    # Convert R integer to ruby Fixnum
    class IntegerConverter
      
      # Convert R object to ruby format
      # 
      # If the R object is an integer, converts it into a ruby Fixnum
      # 
      # @param [REXP] rexp rexp to convert
      # @return [Array] an array of size 2 where first element is a boolean indicating succes,
      #   and the second element is the converted object if conversion successful    
      def convert(rexp)
        if rexp.kind_of?(REXP) and rexp.isInteger and rexp.length == 1
          [true, rexp.asInteger]
        else
          [false, nil]
        end
      end
    end
    
  end
end
