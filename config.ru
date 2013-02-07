require 'rubygems'
require 'bundler/setup'
require 'json'
require 'rack/coffee_compiler'
require 'sinatra'
require 'sinatra/json'

use Rack::CoffeeCompiler, :source_dir => 'coffeescripts', :url => '/javascripts'
use Rack::Static, :urls => ['/javascripts']

get '/' do
  haml :index
end

get '/rdio' do
  haml :rdio
end

get '/time.json' do
  json(time: Time.now.to_f, bpm: ENV['bpm'])
end

run Sinatra::Application
