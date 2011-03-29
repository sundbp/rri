java_import "org.rosuda.REngine.REXPString"

module Rri
  module RConverters
    
    # Converter for ruby Strings
    #
    # Convert ruby Strings to character vector in R
    class StringConverter
      
      # Convert ruby object to R format
      # 
      # If the ruby object is a String, converts it into an R character vector
      # 
      # @param obj object to convert
      # @return [Array] an array of size 2 where first element is a boolean indicating succes,
      #   and the second element is the converted object if conversion successful    
      def convert(obj)
        if obj.kind_of? String
          [true, REXPString.new(obj)]
        else
          [false, nil]
        end
      end
    end
    
  end
end