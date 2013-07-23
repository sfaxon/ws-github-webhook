require 'em-hiredis'
require 'sinatra/base'

EM.run {
  @redis_c = EM::Hiredis.connect
  puts "Posting 'Hello Foo'"
  @redis_c.publish("foo", "Hello Foo")
}

EM.close