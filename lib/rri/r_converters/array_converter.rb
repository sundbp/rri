require 'rri/rexp'

module Rri
  module RConverters
    
    # Converter for ruby Arrays
    class ArrayConverter
      
      # Convert ruby object to R format
      # 
      # If the ruby object is an Array, converts it into an R object.
      #
      # Does not deal with empty arrays.
      #
      # Depending on what type of content the ruby array has, different things happen:
      # * if all elements are doubles, convert to vector of doubles
      # * if all elements are integers, convert to vector of integers
      # * if all elements are strings, convert to vector of strings
      # 
      # @param obj object to convert
      # @return [Array] an array of size 2 where first element is a boolean indicating succes,
      #   and the second element is the converted object if conversion successful    
      def convert(obj)
        if obj.kind_of? Array and obj.size > 0
          if is_all_same_type?(obj)
            o = obj[0]
            return [true, create_integer_vector(obj)] if o.kind_of? Integer
            return [true, create_double_vector(obj)] if o.kind_of? Float
            return [true, create_string_vector(obj)] if o.kind_of? String
            [false, nil]
          end
        else
          [false, nil]
        end
      end
      
      ########################## PRIVATE METHODS #########################
      
      private
      
      def is_all_same_type?(array)
        array.map {|x| x.class}.uniq.size == 1
      end
      
      def create_integer_vector(array)
        REXPInteger.new(array.to_java :int)
      end
      
      def create_double_vector(array)
        REXPDouble.new(array.to_java :double)
      end

      def create_string_vector(array)
        REXPString.new(array.to_java :string)
      end
    end
    
  end
end
