# Mongrel:  Simple Fast Mostly Ruby Web Server

Mongrel is a small library that provides a very fast HTTP 1.1 server for Ruby web applications.  It is not particular to any framework, and is intended to be just enough to get a web application running behind a more complete and robust web server.

What makes Mongrel so fast is the careful use of an Ragel extension to provide fast, accurate HTTP 1.1 protocol parsing. This makes the server scream without too many portability issues.

See http://mongrel.rubyforge.org for more information.

## Compiling for Ruby 1.9

You should just be able to do `gem install mongrel-1.1.6.gem` and it will install. If you need to re-build the gem, run `gem build mongrel.gemspec`. 

## License

Mongrel is copyright 2007 Zed A. Shaw and contributors. It is licensed under the Ruby license and the GPL2. See the include LICENSE file for details.

## Quick Start

The easiest way to get started with Mongrel is to install it via RubyGems and then run a Ruby on Rails application. You can do this easily:

    $ gem install mongrel

Now you should have the mongrel_rails command available in your PATH, so just do the following:

    $ cd myrailsapp
    $ mongrel_rails start

This will start it in the foreground so you can play with it.  It runs your application in production mode.  To get help do:

    $ mongrel_rails start -h 

Finally, you can then start in background mode:

    $ mongrel_rails start -d

And you can stop it whenever you like with:

    $ mongrel_rails stop

All of which should be done from your application's directory.  It writes the PID of the process you ran into log/mongrel.pid.

There are also many more new options for configuring the rails runner including changing to a different directory, adding more MIME types, and setting processor threads and timeouts.

## Install

It doesn't explicitly require Camping, but if you want to run the examples/camping/ examples then you'll need to install Camping 1.2 at least (and redcloth I think). These are all available from RubyGems.

The library consists of a C extension so you'll need a C compiler or at least a friend who can build it for you.

Finally, the source includes a setup.rb for those who hate RubyGems.

## Usage

The examples/simpletest.rb file has the following code as the simplest example:

    require 'mongrel'
    
    class SimpleHandler < Mongrel::HttpHandler
       def process(request, response)
         response.start(200) do |head,out|
           head["Content-Type"] = "text/plain"
           out.write("hello!\n")
         end
       end
    end
    
    h = Mongrel::HttpServer.new("0.0.0.0", "3000")
    h.register("/test", SimpleHandler.new)
    h.register("/files", Mongrel::DirHandler.new("."))
    h.run.join

If you run this and access port 3000 with a browser it will say "hello!".  If you access it with any url other than "/test" it will give a simple 404.  Check out the Mongrel::Error404Handler for a basic way to give a more complex 404 message.

This also shows the DirHandler with directory listings.  This is still rough but it should work for basic hosting.  *File extension to mime type mapping is missing though.*

## Contact

E-mail the Mongrel list at http://rubyforge.org/mailman/listinfo/mongrel-users and someone will help you. Comments about the API are welcome.
