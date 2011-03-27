require 'rri/jri'

module Rri
  
  # The main class to interface with R
  # 
  # Engine internally holds an instance of the java class JRIEngine
  # which is used for all interaction with R. On top of this it provides
  # a few abstractions to easily convert between ruby and R types.
  # 
  # The main methods of the high level API are (#eval_and_convert) and (#convert_and_assign).
  # It also provides a couple of helper methods just to make the users life easier when
  # working with the lower level java API, most notably (#simple_eval) and (#simple_assign).
  # 
  # Apart from the high level API and the helper methods the user can use any other method
  # on JRIEngine, it will be forwarded via method_missing.
  class Engine
    
    # Default options used when creating an engine
    DEFAULT_ENGINE_OPTIONS = {
      :r_arguments => ["--no-save"],
      :callback_object => nil,
      :run_repl => false
    }
    
    # Create a new instance of Engine
    # 
    # @param [nil|Hash] options Either a Hash of options to override the defaults, or not given
    #   in which case the defaults will be used.
    def initialize(*options)
      combined_options = case options.size
      when 0
        DEFAULT_ENGINE_OPTIONS
      when 1
        DEFAULT_ENGINE_OPTIONS.merge(options[0])
      else
        raise RriException.new("Can only take 0 or 1 arguments!")
      end
      
      @engine = Jri::JRIEngine.new(combined_options[:r_arguments].to_java(:string),
                                   combined_options[:callback_object],
                                   combined_options[:run_repl])
    end
    
    # Eval expression and convert result to the corresponding ruby type
    # @param [String] expression the R epxression to evaluate
    # @return the result converted to the corresponding ruby type
    def eval_and_convert(expression)
      convert_to_ruby_type(@engine.parseAndEval(expression))
    end

    # Convert a ruby value to an R type and assign it to an R variable.
    # @param obj ruby object to convert and assign to R varible
    # @return [nil]
    def convert_and_assign(obj)
    end
    
    # Helper method to evaluate expressions but avoid any R-to-ruby conversions
    # 
    # Always uses the global environment and returns an R reference which the
    # user can pass along to other R functions later on.
    # 
    # @param [String] expression the R expression to evaluate
    # @return [REXPReference] reference to the result of the expression
    def simple_eval(expression)
      parsed_expression = @engine.parse(expression, false)
      @engine.eval(parsed_expression, nil, false)
    end
    
    # Helper method to assign expressions to R variables
    # 
    # Always uses the global environment.
    # 
    # @param [#to_s] symbol the symbol to use for the R variable name
    # @return [nil]
    def simple_assign(symbol, rexp)
      @engine.assign(symbol.to_s, rexp, nil)
    end
    
    # Forward any method calls not recognized to JRIEngine
    def method_missing(method, *args, &block)
      @engine.send(method, *args, &block)
    end
    
    ############################ PRIVATE METHODS ##############################

    private
    
    def convert_to_ruby_type(rexp)
      # p rexp.length
      # rexp.methods.each do |method|
      #   next unless method =~ /^is[^_].*/
      #   puts "Converting - checking #{method}: #{rexp.send(method)}"
      # end
      if rexp.isEnvironment
        rexp
      elsif rexp.isNull
        nil
      elsif rexp.isReference
        rexp
      elsif rexp.isSymbol
        rexp
      elsif rexp.isVector
        convert_vector(rexp)
      else
        rexp
      end
    end
    
    def convert_vector(rexp)
      # TODO: assumes all vectors are just size 1 double vectors
      rexp.asDouble
    end
    
    def convert_to_r_type(obj)
      # TODO: implement!
    end
    
  end
end