require 'em-hiredis'
require 'sinatra/base'

EM.run {
  @redis = EM::Hiredis.connect
  class App < Sinatra::Base
    get '/' do
      @redis_c = EM::Hiredis.connect
      puts "request to /"
      @redis_c.publish("foo", "Request to /")
    end
    
    get '/post' do
      
    end
  end
  
  # EM.add_periodic_timer(1) {
  #   @redis.publish("foo", "Hello")
  # }

  App.run!({:port => 3003})
}
