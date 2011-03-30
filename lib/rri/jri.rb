require 'java'

module Rri
  module Jri
    
    def self.jars
      ["JRI", "JRIEngine", "REngine" ]
    end
    
    Jri.jars.each do |jar|
      raise "You must set RRI_JRI_JAR_PATH!" if ENV['RRI_JRI_JAR_PATH'].nil?
      begin
        require File.join(ENV['RRI_JRI_JAR_PATH'], jar)
      rescue LoadError => e
        STDERR.puts e.message
        STDERR.puts "Make sure you have set RRI_JRI_JAR_PATH to the result of the R command: system.file(\"jri\",package=\"rJava\")"
        STDERR.puts "Also, make sure your OS can load dynamic libraries from that directory. E.g. on windows that means it needs to be part of the PATH"
        exit -1
      end
    end
    
    include_package "org.rosuda.REngine.JRI"
  end
end