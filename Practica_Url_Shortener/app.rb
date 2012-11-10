require 'sinatra'
require 'sinatra/activerecord'
require 'haml'

set :database, 'sqlite3:///shortened_urls.db'
set :address, 'localhost:4567'
#set :address, 'exthost.etsii.ull.es:4567'

class ShortenedUrl < ActiveRecord::Base
  # Validates whether the value of the specified attributes are unique across the system.
  validates_uniqueness_of :url
  # Validates that the specified attributes are not blank
  validates_presence_of :url
  #validates_format_of :url, :with => /.*/
  validates_format_of :url, 
       :with => %r{^(https?|ftp)://.+}i, 
       :allow_blank => true, 
       :message => "The URL must start with http://, https://, or ftp:// ."
end


get '/' do
  haml :index
end

get '/show' do
	urls = ShortenedUrl.find(:all)
	@url_list = []
	urls.each do |element|
		@url_list.push([element.url, element])
	end
	haml :show
end

get '/searchShorter' do
	haml :searchShorter
end

get '/searchURL' do
	haml :searchURL
end

get '/:shortened' do
	short_url = ShortenedUrl.find_by_custom_url(params[:shortened])
	begin
	redirect short_url.url
	rescue
		short_url = ShortenedUrl.find(params[:shortened].to_i(36))
		redirect short_url.url
	end
end

post '/' do
	@short_url = ShortenedUrl.new(:url =>params[:url],:custom_url =>params[:custom_url])
	if !params[:custom_url].empty?
		begin
			@duplicate_custom = ShortenedUrl.find_by_custom_url(params[:custom_url])
		rescue
			@duplicate_custom = nil
		end
	end
	if @short_url.valid? && @duplicate_custom.nil?
		@short_url.save
		haml :success, :locals => { :address => settings.address }
	else
		haml :index
	end
end

post '/searchShorter' do
	begin
		@result = ShortenedUrl.find(params[:shorturl].to_i(36))
	rescue
		@result = ShortenedUrl.find_by_custom_url(params[:shorturl])
	end
	haml :searchShorter
end

post '/searchURL' do
	begin	
		@result = ShortenedUrl.find_by_url(params[:url])
	rescue
		@result = nil
	end
	haml :searchURL
end



