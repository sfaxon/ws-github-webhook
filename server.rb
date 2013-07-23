require 'rubygems'
require 'em-websocket'
require 'sinatra/base'
require 'thin'
require 'erb'
require 'json'
require 'em-hiredis'

# Store sessions in memory - keyed by the object_id of
# the underlying websocket connection.  Since we always
# get the same ws connection back with the same object_id
# this seemed like a good safe hash key to use.
class SessionStore
  def initialize
    @sessions = Hash.new
  end

  def <<(session)
    session.session_store = self
    @sessions[ session.connection.object_id ] = session
  end

  def delete_for_connection(ws)
    @sessions.delete(ws.object_id)
  end

  def with_connection(ws,&blk)
    yield @sessions[ ws.object_id ]
  end

  def each_peer(session, &blk)
    @sessions.values.reject { |s| s == session }.each { |s| yield s }
  end

  def each(&blk)
    @sessions.values.each { |s| yield s }
  end
end

class ClientSession
  attr_accessor :connection, :session_store
  def initialize(ws)
    @session_store = nil
    @connection = ws
  end

  def send(message)
    puts "--> %s" % message.to_json
    @connection.send( message )
  end
end

EM.run do
  class App < Sinatra::Base
    get '/' do
      @redis_c = EM::Hiredis.connect
      puts 'request to /'
      erb :index
    end
    
    post '/post' do
      puts 'calling post'
      @redis_c = EM::Hiredis.connect
      @redis_c.publish("foo", request.body.read)
    end
  end
    
  @redis = EM::Hiredis.connect
  @sessions = SessionStore.new

  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 3001) do |ws|
    ws.onopen {
      @sessions << ClientSession.new(ws)

      @redis.pubsub.subscribe("foo") { |msg|
        @sessions.each { |s| s.send(msg) }
      }
      
      # @sessions << ClientSession.new(ws)
      ws.onmessage { |packet|
        @sessions.with_connection(ws) do |session|
          # session.receive( ChatMessage.parse(packet) )
        end
      }
    }
    
    ws.onclose {
      left = @sessions.delete_for_connection(ws)
    }

  end

  App.run!({:port => 3000})
end