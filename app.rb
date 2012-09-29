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
get '/readme' do
  markdown_text = File.new(settings.root + '/README.md').read
  markdown markdown_text
end
