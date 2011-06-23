require 'rubygems'
require 'bundler'
Bundler.require
require 'faye'

require File.expand_path('../config/initializers/faye_token.rb', __FILE__)

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if message['ext']['auth_token'] != FAYE_TOKEN
        message['error'] = 'Invalid authentication token'
      end
    end
    callback.call(message)
  end
end

faye_server = Faye::RackAdapter.new(
			:mount => '/faye', 
			:timeout => 45,
			:engine => {
				:type => 'redis',
				:host => 'barreleye.redistogo.com',
				:port => '9214',
				:password => '5f4c833f7c4ce09ad41eceb26db27be1',
				:database => 1
			})
faye_server.add_extension(ServerAuth.new)
run faye_server
