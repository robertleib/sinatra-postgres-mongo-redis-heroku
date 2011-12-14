require 'rubygems'
require 'sinatra'
require 'rack/parser'
require 'active_record'
require 'mongoid'
require 'pg'
require 'rack/throttle'
require 'dalli'
require 'redis'
require 'resque'

use Rack::Parser, :content_types => {
  'application/json'  => Proc.new { |body| ::MultiJson.decode body }
}

class App < Sinatra::Application
  configure do
    ENV['RACK_ENV'] = ENV['RACK_ENV'] || environment.to_s
    YAML::load(File.open('config/database.yml'))[ENV['RACK_ENV']].symbolize_keys.each do |key, value|
      set key, value
    end
    
    ActiveRecord::Base.establish_connection(
      adapter: "postgresql", 
      host: settings.host,
      database: settings.database,
      username: settings.username,
      password: settings.password)
    
    Mongoid.configure do |config|
      if ENV['MONGOLAB_URI']
        conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
        uri = URI.parse(ENV['MONGOLAB_URI'])
        config.master = conn.db(uri.path.gsub(/^\//, ''))
      else
        config.master = Mongo::Connection.from_uri("mongodb://localhost:27017").db('sinatra_app_development')
      end
    end
    
  end
  
  configure :development do
    enable :logging, :dump_errors, :raise_errors
    
    set :cache, Dalli::Client.new
    
    REDIS = Redis.new(:host => "127.0.0.1", :port => 6379, :password => "")
    
    use Rack::Throttle::Hourly,   :max => 1000, :cache => REDIS, :key_prefix => 'throttle_sinatra_app'
    Resque.redis = REDIS
  end

  configure :test do
    enable :logging, :dump_errors, :raise_errors
  end

  configure :production do
    enable :logging, :dump_errors, :raise_errors
    
    ENV["LOG_LEVEL"] = "DEBUG"
    
    set :cache, Dalli::Client.new
    
    uri = URI.parse(ENV["REDISTOGO_URL"])

    REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    
    use Rack::Throttle::Hourly,   :max => 1000, :cache => REDIS, :key_prefix => :throttle
    Resque.redis = REDIS
    
  end
  
  configure :staging do
    enable :logging, :dump_errors, :raise_errors
    
    set :cache, Dalli::Client.new
    
    uri = URI.parse(ENV["REDISTOGO_URL"])
    
    REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    
    use Rack::Throttle::Hourly,   :max => 1000, :cache => REDIS, :key_prefix => :throttle
    Resque.redis = REDIS
  end
end

require_relative 'routes/init'
#require_relative 'lib/helpers/init'
require_relative 'models/init'
