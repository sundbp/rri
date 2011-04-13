require 'rri/rexp'

module Rri
  module RubyConverters
    
    # Converter for R Integers
    #
    # Convert R character vector to ruby String
    class StringConverter
      
      # Convert R object to ruby format
      # 
      # If the R object is a character vector, converts it into a ruby String
      # 
      # @param [REXP] rexp rexp to convert
      # @return [Array] an array of size 2 where first element is a boolean indicating succes,
      #   and the second element is the converted object if conversion successful    
      def convert(rexp)
        if rexp.kind_of?(REXP) and rexp.isString
          [true, rexp.asString]
        else
          [false, nil]
        end
      end
    end
    
  end
end
