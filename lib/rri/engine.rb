require 'rri/jri'
require 'rri/r_converters'
require 'rri/ruby_converters'

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

    # Add a custom converter used to convert ruby objects to R objects
    #
    # @param [#convert] converter the converter to add
    # @return [Array] known (class level) converters
    def self.add_r_converter(converter)
      @@r_converters ||= []
      @@r_converters << converter
    end
    
    # Get all class level custom converters to convert ruby objects to R objects
    #
    # Converters are returned in the reversed order to how they were added
    # (i.e. the last added is applied first)
    #
    # @return [Array] all class level custom converters
    def self.r_converters
      @@r_converters ||= []
      @@r_converters.reverse
    end

    # Clear all class level custom R converters
    def self.clear_r_converters
      @@r_converters = []
    end
    
    # Get default converters to convert ruby objects to R objects
    #
    # @return [Array] all default converters
    def self.default_r_converters
      [
        RConverters::FloatConverter.new,
        RConverters::IntegerConverter.new,
        RConverters::StringConverter.new,
        RConverters::ArrayConverter.new
      ]
    end

    # Add a custom converter used to convert R objects to ruby objects
    #
    # @param [#convert] converter the converter to add
    # @return [Array] known (class level) converters
    def self.add_ruby_converter(converter)
      @@ruby_converters ||= []
      @@ruby_converters << converter
    end
    
    # Get all class level custom converters to convert R objects to ruby objects
    #
    # Converters are returned in the reversed order to how they were added
    # (i.e. the last added is applied first)
    #
    # @return [Array] all class level custom converters
    def self.ruby_converters
      @@ruby_converters ||= []
      @@ruby_converters.reverse
    end

    # Clear all class level custom ruby converters
    def self.clear_ruby_converters
      @@ruby_converters = []
    end

    # Get default converters to convert R objects to ruby objects
    #
    # @return [Array] all default converters
    def self.default_ruby_converters
      [
        #RubyConverters::DoubleConverter.new,
        RubyConverters::IntegerConverter.new,
        #RubyConverters::StringConverter.new,
      ]
    end

    # Helper to make sure all engines are finalized so the R thread dies as it should
    #
    # @param engine engine to finalize
    # @return [Proc] that closes the engine
    def self.finalize(engine)
      proc { engine.close }
    end
    
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
                                  
      # the R thread wont die unless we call #close on @engine, so make sure this
      # happens when this object is finalized.
      ObjectSpace.define_finalizer(self, self.class.finalize(@engine))
    end

    # Forward any method calls not recognized to JRIEngine
    def method_missing(method, *args, &block)
      if @engine.respond_to? method
        @engine.send(method, *args, &block)
      else
        super
      end
    end

    # Add a custom converter used to convert ruby objects to R objects
    #
    # @param [#convert] converter the converter to add
    # @return [Array] known (instance level) converters
    def add_r_converter(converter)
      @r_converters ||= []
      @r_converters << converter
    end
    
    # Get all instance level custom converters to convert ruby objects to R objects
    #
    # Converters are returned in the reversed order to how they were added
    # (i.e. the last added is applied first)
    #
    # @return [Array] all instance level custom converters
    def r_converters
      @r_converters ||= []
      @r_converters.reverse
    end

    # Clear all instance level custom R converters
    def clear_r_converters
      @r_converters = []
    end
    
    # Add a custom converter used to convert R objects to ruby objects
    #
    # @param [#convert] converter the converter to add
    # @return [Array] known (instance level) converters
    def add_ruby_converter(converter)
      @ruby_converters ||= []
      @ruby_converters << converter
    end

    # Clear all instance level custom R converters
    def clear_ruby_converters
      @ruby_converters = []
    end

    # Get all instance level custom converters to convert R objects to ruby objects
    #
    # Converters are returned in the reversed order to how they were added
    # (i.e. the last added is applied first)
    #
    # @return [Array] all instance level custom converters
    def ruby_converters
      @ruby_converters ||= []
      @ruby_converters.reverse
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
    
    # Eval expression and convert result to the corresponding ruby type
    #
    # @param [String] expression the R epxression to evaluate
    # @return the result converted to the corresponding ruby type
    def eval_and_convert(expression)
      convert_to_ruby_type(@engine.parseAndEval(expression))
    end

    # Helper method to assign expressions to R variables
    # 
    # Always uses the global environment.
    # 
    # @param [#to_s] symbol what to call the R variable
    # @return [nil]
    def simple_assign(symbol, rexp)
      @engine.assign(symbol.to_s, rexp, nil)
    end
    
    # Convert a ruby value to an R type and assign it to an R variable.
    #
    # @param obj ruby object to convert and assign to R varible
    # @param [#to_s] symbol what to call the R variable
    # @return [nil]
    def convert_and_assign(obj, symbol)
      success, rexp = convert_to_r_object(obj)
      raise RriException.new("Failed to convert ruby object to R object for: #{obj}") unless success
      simple_assign(symbol, rexp)
    end
    
    # Helper method to get a variable from R
    #
    # Always uses the global environment.
    # 
    # @param [#to_s] symbol name of the R variable to get
    # @return [REXPReference] reference to the R variable
    def simple_get(symbol)
      @engine.get(symbol.to_s, nil, false)
    end

    # Get a variable from R and convert it to a ruby object
    #
    # Always uses the global environment.
    # 
    # @param [#to_s] symbol name of the R variable to get
    # @return the R variable converted to a ruby object
    def get_and_convert(symbol)
      rexp = @engine.get(symbol.to_s, nil, true)
      success, value = convert_to_ruby_object(rexp)
      raise RriException.new("Failed to convert R object to ruby object for: #{value}") unless success
      value
    end
    
    # Convert a ruby object to a R object
    #
    # Applies converters in 3 levels:
    # * custom converters that is set for only this engine instance
    # * custom converters that are set for all engine instances
    # * default converters
    #
    # Converters are applied in the reverse order they were added in.
    #
    # @param obj ruby object to convert
    # @return [Array] an array of size 2 where first element is a boolean indicating succes,
    #   and the second element is the converted object if conversion successful (otherwise
    #   the original obj)
    def convert_to_r_object(obj)
      # first try converters defined for just this instance
      success, value = apply_local_r_converters(obj)
      return [success, value] if success

      # then try converters defined in general
      success, value = apply_r_converters(obj)
      return [success, value] if success

      # and finally apply the default converters   
      success, value = apply_default_r_converters(obj)
      return [success, value] if success

      # give up
      [false, obj]
    end

    # Convert an R object to a ruby object
    #
    # Applies converters in 3 levels:
    # * custom converters that is set for only this engine instance
    # * custom converters that are set for all engine instances
    # * default converters
    #
    # Converters are applied in the reverse order they were added in.
    #
    # @param [REXP] rexp R object to convert
    # @return [Array] an array of size 2 where first element is a boolean indicating succes,
    #   and the second element is the converted object if conversion was successful (otherwise
    #   the original rexp)
    def convert_to_ruby_object(rexp)
      # first try converters defined for just this instance
      success, value = apply_local_ruby_converters(rexp)
      return [success, value] if success

      # then try converters defined in general
      success, value = apply_ruby_converters(rexp)
      return [success, value] if success

      # and finally apply the default converters   
      success, value = apply_default_ruby_converters(rexp)
      return [success, value] if success

      # give up
      [false, rexp]
    end

    ############################ PRIVATE METHODS ##############################

    private

    # Helper method to apply converters
    #
    # @param [Array] converters array of converters to try to apply
    # @param obj object to try to convert
    # @return [Array] an array of size 2 where first element is a boolean indicating succes,
    #   and the second element is the converted object if conversion was successful    
    def apply_converters(converters, obj)
      converters.each do |converter|
        success, value = converter.convert(obj)
        return [success, value] if success
      end
      # if no success, return failure and nil for value
      [false, nil]
    end
      
    # Apply custom converters that are defined just for this engine to a ruby object
    #
    # @param obj ruby object to convert to R type
    # @return [Array] an array of size 2 where first element is a boolean indicating succes,
    #   and the second element is the converted object if conversion was successful
    def apply_local_r_converters(obj)
      apply_converters(r_converters, obj)
    end

    # Apply custom converters that are defined for all engines to a ruby object
    #
    # @param obj ruby object to convert to R type
    # @return [Array] an array of size 2 where first element is a boolean indicating succes,
    #   and the second element is the converted object if conversion was successful
    def apply_r_converters(obj)
      apply_converters(Engine.r_converters, obj)
    end

    # Apply default converters to ruby object
    #
    # @param obj ruby object to convert to R type
    # @return [Array] an array of size 2 where first element is a boolean indicating succes,
    #   and the second element is the converted object if conversion was successful
    def apply_default_r_converters(obj)
      apply_converters(Engine.default_r_converters, obj)
    end

    # Apply custom converters that are defined just for this engine to an R object
    #
    # @param [REXP] rexp object to convert to ruby object
    # @return [Array] an array of size 2 where first element is a boolean indicating succes,
    #   and the second element is the converted object if conversion was successful
    def apply_local_ruby_converters(rexp)
      apply_converters(ruby_converters, rexp)
    end

    # Apply custom converters that are defined for all engines to an R object
    #
    # @param [REXP] rexp R object to convert to ruby object
    # @return [Array] an array of size 2 where first element is a boolean indicating succes,
    #   and the second element is the converted object if conversion was successful
    def apply_ruby_converters(rexp)
      apply_converters(Engine.ruby_converters, rexp)
    end

    # Apply default converters to R object
    #
    # @param [REXP] rexp R object to convert to ruby object
    # @return [Array] an array of size 2 where first element is a boolean indicating succes,
    #   and the second element is the converted object if conversion was successful
    def apply_default_ruby_converters(rexp)
      apply_converters(Engine.default_ruby_converters, rexp)
    end

  end
end