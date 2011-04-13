require 'rri/rexp'

module Rri
  module RubyConverters
    
    # Converter for R NULL
    #
    # Convert R integer to ruby nil
    class NullConverter
      
      # Convert R object to ruby format
      # 
      # If the R object is NULL, converts it into a ruby nil
      # 
      # @param [REXP] rexp rexp to convert
      # @return [Array] an array of size 2 where first element is a boolean indicating succes,
      #   and the second element is the converted object if conversion successful    
      def convert(rexp)
        if rexp.kind_of?(REXP) and rexp.isNull
          [true, nil]
        else
          [false, nil]
        end
      end
    end
    
  end
end
