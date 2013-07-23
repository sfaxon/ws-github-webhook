ws-github-webhook
=================

Playing with web sockets to push notifications to clients using websockets. 

Sinatra app receives a post from github webhook and updates all subscribed clients.
em-hiredis is used to pass things from server to websockt. 

Running it
=============

bundle

bundle exec ruby server.rb

http://localhost:3000/

Credit
======

heavily modified from github.com/alibby/ws-chat 


MIT Licenced, hack, fork, whatever.

