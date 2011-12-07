#!/usr/bin/env ruby
require 'logger'

$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')
require 'resque/server'

# Set the RESQUECONFIG env variable if you've a `resque.rb` or similar
# config file you want loaded on boot.
if ENV['RESQUECONFIG'] && ::File.exists?(::File.expand_path(ENV['RESQUECONFIG']))
  load ::File.expand_path(ENV['RESQUECONFIG'])
end

# Set the AUTH env variable to your basic auth password to protect Resque.
# If it contains a ":" it's split (at the first ":")
# to have a username and a password,
# otherwise, it's just the password, and any username will work.
CREDENTIALS = ENV['AUTH']
if CREDENTIALS
  Resque::Server.use Rack::Auth::Basic do |username, password|
    credentials = CREDENTIALS.split(':',2)
    if credentials.size == 2
      [username, password] == credentials
    else
      password == credentials[0]
    end
  end
end

use Rack::ShowExceptions
run Resque::Server.new
