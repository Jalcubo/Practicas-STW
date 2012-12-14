# coding: utf-8
require 'sinatra'
set server: 'thin', connections: []

$usr_list = []

get '/' do
  halt erb(:login) unless params[:user]
  $user = params[:user].gsub(/\W/, '')
  $usr_list.push($user) 
  erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
end

get '/form' do
	erb :form
	
end
get '/text' do
	erb :text
end


get '/stream', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    out.callback { settings.connections.delete(out) }
  end
end

get '/users' do
 # while 1 < 2 do
	erb :users
 # end
end

post '/' do
  settings.connections.each { |out| out << "data: #{params[:msg]}\n\n" }
  204 # response without entity body
end




