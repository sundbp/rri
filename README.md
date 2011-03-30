# rri

* [Homepage](https://github.com/sundbp/rri)
* [Documentation](http://rubydoc.info/gems/rri/frames)

## Description

This gem provides an interface from ruby to R by using [JRI](http://www.rforge.net/JRI/) 
(the Java/R Interface) from JRuby. JRI is a well established way of interfacing with R from Java
and hence a great building block to enable JRuby to interface with R.

This gem also enables the use of the R package [JavaGD](http://www.rforge.net/JavaGD/). JavaGD is
a R graphics device used to output graphics to a Java class. This makes it possible to easily
integrate R graphics with java/JVM GUI applications (for example it is used by
[JGR](http://www.rforge.net/JGR/)). JavaGD allows you to provide a custom class used for painting 
which could well be implemented in jruby. Read the JavaGD package documentation for more information.

At the moment this gem is mostly aimed towards using R from ruby, but there's nothing stopping us
from taking advantage of [rJava](http://www.rforge.net/rJava/) to also allow R to call into jruby.

## Features

* Call R functions from ruby
* An extendible system for converting between R and ruby data types (in both directions)
* Plot R graphics using user supplied class

## Examples

    require 'rri'
    
    engine = Rri::Engine.new
    
    # high level API, converts results and arguments from and to R/ruby
    result = engine.eval_and_convert("1.23 + 4.56") # result will be a noromal ruby Float (5.79)
    engine.convert_and_assign(result, :x)           # x = 5.79 in R
    result = engine.get_and_convert(:x)             # result is a ruby Float
    
    # helpers for the low level API, useful when you're not bothered
    # about converting any values to/from R/ruby
    result = engine.simple_eval("x + 1")            # returns a reference to R object
    engine.simple_assign("y", result)               # y = 6.79 in R, assumes the value is an R object, 
                                                    # no conversion takes place.
    result = engine.simple_get(:y)                  # returns a reference to R object
    
    # we should always close an engine, if we don't the R thread
    # seem to hang around forever causing the ruby program to not
    # exit. There is however also a finalizer defined that should
    # automatically take care of this.
    #
    # use normal JRIEngine API via method missing forwarding
    engine.close
    
Please also see the examples in the 'examples/' directory for more interesting use cases.

## Requirements

* An installation of [R](http://www.r-project.org/)
* The R packages **rJava** and **JavaGD**

## Install

First we need the rri gem:

    $ gem install rri

Next we switch to R to install the required R packages:

    > install.packages(c("rJava", "JavaGD"))

After this we need to make sure rri is able to find the needed jar-files. rri will attempt
to read the jars in the path specified by the environment variables:

* **RRI_JRI_JAR_PATH**
* **RRI_JAVAGD_JAR_PATH**

Set the first environment variable to the path given by the following R command:

    > system.file("jri",package="rJava")
  
and the second one to the path given by:

    > system.file("java", package="JavaGD")

Make sure the OS can load dynamic libraries from the R directory. On Windows that means
making it part of the path. On my machine it means adding "C:\Program Files\R\R-2.12.1\bin\i386"
to the **PATH**.

The last thing we need to make sure of is that the shared library distributed with JRI is
accessible by the operating system. I have not gone over this exercise on unix type systems
yet but on Windows this means that the path set in **RRI_JRI_JAR_PATH** is also part of the
**PATH**.

I tried to add this to the path within the rri gem itself before loading the JRI jars
but it seems the jruby class loader fails to pick it up so it needs to be part of the **PATH** 
before a program using rri is launched. On linux like systems I'd expect there may be a need
for something similar in relation to **LD_LIBRARY_PATH** but I haven't had a chance to test it yet.

## Type conversions

R and ruby have quite different type systems, but at least for the most common types of
data we can implement some natural conversions (in both directions).

Type conversion in both directions are tried in 3 levels:
* first custom specified (user) converters for a given engine are tried
* then custom specified (user) converters applicable to all engines are tried
* and finally a set of default converters specified by rri itself are applied

For custom converters the order in which they are tried is the reverse order
in which they were added, so the latest added converter is tried first.

To write your own custom converters please take a look at the default ones
in rri/r_converters and rri/ruby_converters. For help with the R type system
the REXP [JavaDocs](http://www.rforge.net/org/docs/org/rosuda/REngine/REXP.html)
are a good place to start.

**TODO**: describe the default converters, for now best docs are the specs

## Note about instantiating engines many times in the same process

There seem to be issues in the C layer of either JRI or the R library when
you create an engine many times in the same process. That applies also if
you never have more than one engine created at any one time.

Emperically I get an infinite hang in the C layer if I re-create an engine
more than ~12 times in the same process.

## Copyright

Copyright (c) 2011 Patrik Sundberg

See {file:LICENSE.txt} for details.
