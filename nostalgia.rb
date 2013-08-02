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
enable :sessions
set :session_secret, ENV['SESSION_SECRET'] || 'gibberish'

Mongoid.load!('mongoid.yml')

before do
  if session['email']
    @user = User.find_by(email: session['email'])
  end
end

get '/' do
  if @user
    foursquare= FourSquare.new
    foursquare.token = @user.token
    @checkins = foursquare.year_ago['response']['checkins']['items'].sort_by!{|c| c['createdAt']}
  end
  haml :index
end

get '/login' do
  if session['email']
    redirect to('/')
  else
    redirect to(FourSquare::AUTH_URL)
  end
end

get '/logout' do
  session.destroy
  redirect to('/')
end

get '/disconnect' do
  haml :diconnect
end

get '/disconnect_confirmed' do
  session.destroy
  @user.destroy
  @user = nil
  haml :disconnect_confirmed
end

get '/fsq/callback'  do
  code = params[:code]
  foursquare = FourSquare.new
  foursquare.token = foursquare.get_token(code)
  session['token'] = foursquare.token
  user_attrs = foursquare.user_info['response']['user']
  email = user_attrs['contact']['email']
  user = User.find_or_initialize_by(email: email)
  user.token = foursquare.token
  user.save!
  session['email'] = user.email
  redirect to('/')
end

