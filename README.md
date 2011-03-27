# rri

* [Homepage](http://rubygems.org/gems/rri)
* [Documentation](http://rubydoc.info/gems/rri/frames)

## Description

This gem wraps enables an interface from ruby to R by using [JRI](http://www.rforge.net/JRI/) 
(the Java/R Interface) from JRuby. JRI is a well established way of interfacing with R from Java
and hence a great building block to enable JRuby to interface with R.

This gem also enables the use of the R package [JavaGD](http://www.rforge.net/JavaGD/). JavaGD is
a R graphics device used to output graphics to a Java class. This makes it possible to easily
integrate R graphics with java/JVM GUI applications (for example it is used by
[JGR](http://www.rforge.net/JGR/)). JavaGD allows you to provide a custom class used for painting 
which could well be implemented in jruby. Read the JavaGD pckage documentation for more information.

At the moment this gem is mostly aimed towards using R from ruby, but there's nothing stopping us
from taking advantage of [rJava](http://www.rforge.net/rJava/) to also allow R to call into jruby.

## Features

* Call R functions from ruby
* Plot R graphics using user supplied class

## Examples

    require 'rri'

## Requirements

* An installation of [R](http://www.r-project.org/)
* The R packages "rJava" and "JavaGD"

## Install

First we need the rri gem:
    $ gem install rri

Next we switch to R to install the required R packages:
    > install.packages(c("rJava", "JavaGD"))

After this we need to make sure rri is able to find the needed jar-files. rri will attempt
to read the jars in the path specified by the environment variables:
* RRI_JRI_JAR_PATH
* RRI_JAVAGD_JAR_PATH

Set the first environment variable to the path given by the following R command:
  > system.file("jri",package="rJava")
and the second one to the path given by:
  > system.file("java", package="JavaGD")

Make sure the OS can load dynamic libraries from the R directory. On windows that means
making it part of the path.

The last thing we need to make sure of is that the shared library distributed with JRI is
accessible by the operating system. I have not gone over this exercise on unix type systems
yet but on Windows this means that the path set in RRI_JRI_JAR_PATH is also part of the
PATH.

I tried trying to add this to the path within the rri gem itself before loading the JRI jar
but it seems the jruby class loader fails to pick it up so it need to be part of the PATH 
before a program using rri is launched. On linux like systems I'd expect there may be a need
for something similar in relation to LD_LIBRARY_PATH.

## Copyright

Copyright (c) 2011 Patrik Sundberg

See {file:LICENSE.txt} for details.
