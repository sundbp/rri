require 'java'

module Rri
  module JavaGd
    
    def self.jars
      ["javaGD" ]
    end
    
    JavaGd.jars.each do |jar|
      raise "You must set RRI_JAVAGD_JAR_PATH!" if ENV['RRI_JAVAGD_JAR_PATH'].nil?
      begin
        require File.join(ENV['RRI_JAVAGD_JAR_PATH'], jar)
      rescue LoadError => e
        STDERR.puts e.message
        STDERR.puts "Make sure you have set RRI_JAVAGD_JAR_PATH to the result of the R command: system.file(\"java\", package=\"JavaGD\")"
        exit -1
      end
    end
    
    include_package "org.rosuda.javaGD"
  end
end