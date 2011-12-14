class App < Sinatra::Application
  
  get '/accounts' do
    
  end
  
  post '/accounts' do
    Account.new(:name => "lowercase", :owner_id => 1234)
  end
  
  get '/accounts/:id' do
    @account = Account.find params[:id]
    last_modified @account.updated_at
    etag @account.updated_at
    ["account: #{@account.id} #{@account.name}"]
  end
  
end
  