require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' # if development?
require 'sprockets'
require 'rack/reverse_proxy'

#Disable protection to get work reverse_proxy
disable :protection

options '/*' do
  200
end

get '/' do
  erb :index
end

##############################################
# Reverse proxy configuration to use the rentpayment api from this server.
use Rack::ReverseProxy do
  #To avoid an ugly ssl error
  reverse_proxy_options :verify_ssl => false

  # Forward the path /api/2 to  https://demo.rentpayment.com/api/2
  reverse_proxy '/pc', 'http://181.80.6.182:9292'
end
##############################################
get '/readme' do
  markdown_text = File.new(settings.root + '/README.md').read
  markdown markdown_text
end
