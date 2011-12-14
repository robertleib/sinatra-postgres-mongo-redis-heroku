
class App < Sinatra::Application
  get '/' do
    #VARNISH
    headers['Cache-Control'] = 'public, max-age=300'
    #MEMCACHE
    color = settings.cache.fetch('color') do
      'blue'
    end
    #REDIS
    REDIS.set("#{Time.now}", "#{Time.now}")
    #RESQUE
    Resque.enqueue(Eat, "hello")
    #MONGODB/MONGOID
    u = User.create(:first_name => 'Bob', :last_name => 'Tester')
    
    #POSTGRES/ACTIVERECORD
    a = Account.create(:name => params[:name] || "mice", :owner_id => 1234)
    
    "user: #{u.id}<br><br>
    account: #{a.id || a.errors}<br><br>
    Hello from #{color} Sinatra on Heroku! #{ENV['RACK_ENV']}, Rendered at #{Time.now}<br><br>
    #{REDIS.keys("throttle*").map{|key| [key, REDIS.get(key)]}}<br><br>
    #{REDIS.keys("*")}<br><br>
    <a href='/resque'>resque</a>"
  end
end