require 'rubygems'
require 'bundler/setup'
require 'json'
require 'rack/coffee_compiler'
require 'sinatra'
require 'sinatra/json'
require 'rdio'

use Rack::CoffeeCompiler, :source_dir => 'coffeescripts', :url => '/javascripts'
use Rack::Static, :urls => ['/javascripts']

enable :sessions

get '/' do
  haml :index
end

get '/rdio' do
  haml :rdio
end

consumer = OAuth::Consumer.new(ENV['RDIO_KEY'], ENV['RDIO_SECRET'],
    :site=> 'http://api.rdio.com',
    :request_token_path => '/oauth/request_token',
    :authorize_path => '/1/oauth/authorize',
    :access_token_path => '/oauth/access_token',
    :http_method => :post
)

get '/auth' do
  request_token=consumer.get_request_token(
      :oauth_callback => 'http://localhost:5000/callback')
  session[:request_token]=request_token

  redirect 'https://www.rdio.com/oauth/authorize?oauth_token=' +
      request_token.token.to_s
end

get '/callback' do
  request_token = session[:request_token]
  session[:access_token] = request_token.get_access_token(
      :oauth_verifier => params[:oauth_verifier])
  'OK!'
end

get '/time.json' do
  json(time: Time.now.to_f, bpm: ENV['bpm'])
end

get '/playback_token.json' do
  Rdio.api.access_token = session[:access_token]
  json :playbackToken => Rdio.api.getPlaybackToken('localhost')
end

run Sinatra::Application
