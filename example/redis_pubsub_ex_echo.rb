require 'em-hiredis'

EM.run {
  redis = EM::Hiredis.connect
  
  puts "Subscribing"
  redis.pubsub.subscribe("foo") { |msg|
    puts [:foo, msg]
  }

}
