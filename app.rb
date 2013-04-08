require 'sinatra/base'
require 'coffee-script'
require 'sass'

class SassEngine < Sinatra::Base  
  set :views, File.dirname(__FILE__) + '/assets/stylesheets'
  
  get '/stylesheets/*.css' do
    filename = params[:splat].first
    sass filename.to_sym
  end
end

class CoffeeEngine < Sinatra::Base
  set :views, File.dirname(__FILE__) + '/assets/javascripts'
  
  get "/javascripts/*.js" do
    filename = params[:splat].first
    coffee filename.to_sym
  end  
end

class App < Sinatra::Base
  use SassEngine
  use CoffeeEngine
  
  get '/' do
    erb :index
  end        
end