require 'rubygems'
require 'bundler/setup'
require 'json'
require 'rack/coffee_compiler'
require 'rack/cache'
require 'sinatra'
require 'sinatra/json'
require 'oauth'

use Rack::Cache
use Rack::CoffeeCompiler, :source_dir => 'coffeescripts', :url => '/javascripts'
use Rack::Static, :urls => ['/javascripts']

module Helpers
  def rdio_api(method, params={})
    access_token = session[:access_token]
    response = access_token.post('/1/',  params.merge('method' => method))
    parsed = JSON.parse(response.body)
    parsed['result']
  end
end

enable :sessions
helpers Helpers

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

  redirect '/rdio'
end

get '/time.json' do
  json(time: Time.now.to_f, bpm: ENV['bpm'])
end

get '/foobar' do
  url = 'http://www.rdio.com/artist/30_Seconds_To_Mars/album/This_Is_War_1/track/Kings_and_Queens/'
  #url = 'http://www.rdio.com/artist/30_Seconds_To_Mars/album/This_Is_War_1/track/This_Is_War/'
  rdio_api('getObjectFromUrl', 'url' => url)
end

get '/playback_token.json' do
  result = rdio_api('getPlaybackToken', 'domain' => 'localhost')
  json :playbackToken => result
end

get '/echonest_profile.json' do
  body = Net::HTTP.get(
      'developer.echonest.com',
      "/api/v4/track/profile?id=rdio-US:track:#{params['rdio_id']}&bucket=audio_summary&api_key=#{ENV['ECHONEST_API_KEY']}")
  parsed = JSON.parse(body)
  analysis_url = parsed['response']['track']['audio_summary']['analysis_url']

  content_type 'application/json'

  # cache for 1 hour
  cache_control 'public', 'max-age=3600'

  uri = URI(analysis_url)
  http = Net::HTTP.new(uri.host, uri.port)
  s3_request = Net::HTTP::Get.new(uri.request_uri)

  # Forward If-Modified-Since request header to S3
  if_modified_since = request.env['HTTP_IF_MODIFIED_SINCE']
  if if_modified_since
    s3_request['If-Modified-Since'] = if_modified_since
  end

  s3_response = http.request(s3_request)
  response['Last-Modified'] = s3_response['Last-Modified']

  status s3_response.code
  s3_response.body
end

run Sinatra::Application
