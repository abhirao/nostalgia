require 'bundler'
Bundler.setup

require 'sinatra'
require 'sinatra/content_for'
require "sinatra/reloader" if development?
require_relative 'lib/foursquare.rb'
require 'haml'
require 'sinatra/twitter-bootstrap'
require 'mongoid'
require_relative 'models/user.rb'

register Sinatra::Twitter::Bootstrap::Assets

use Rack::Session::Pool, :expire_after => 2592000
enable :logging
set :session_secret, 'gibberish'

Mongoid.load!('mongoid.yml')

get '/' do
  if session['token']
    foursquare= FourSquare.new
    foursquare.token = session['token']
    @checkins = foursquare.year_ago['response']['checkins']['items'].sort_by!{|c| c['createdAt']}
  end
  haml :index
end

get '/login' do
  redirect to(FourSquare::AUTH_URL)
end

get '/fsq/callback'  do
  code = params[:code]
  foursquare = FourSquare.new
  foursquare.token = foursquare.get_token(code)
  session['token'] = foursquare.token
  user_attrs = foursquare.user_info['response']['user']
  email = user_attrs['contact']['email']
  User.create!(email: email, token: foursquare.token)
  redirect to('/')
end

