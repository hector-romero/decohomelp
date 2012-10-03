require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' # if development?
require 'sprockets'


options '/*' do
  200
end

before do
  headers 'Content-Language' => 'es'
end

get '/' do

  erb :index
end

get '/favicon.ico' do
  redirect "/assets/dhlogo.png"
end

#
###############################################
#get '/readme*' do
#  markdown_text = File.new(settings.root + '/README.md').read
#  markdown markdown_text
#end
