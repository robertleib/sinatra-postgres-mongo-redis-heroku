require './app.rb'
require 'resque/server'

$stdout.sync = true 

run Rack::URLMap.new \
  "/"       => App.new,
  "/resque" => Resque::Server.new