require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'geocoder'

set :database, 'sqlite3:///shortened_urls.db'
set :address, 'localhost:4567'
#set :address, 'exthost.etsii.ull.es:4567'

class ShortenedUrl < ActiveRecord::Base
  has_many :visits
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

class Visit < ActiveRecord::Base
	belongs_to :shortenedurl
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
get '/info/:short_url' do 
		short_url = ShortenedUrl.find_by_custom_url(params[:short_url])
		begin
			$visitas = Visit.where(:shortened_url_id => short_url.id)
			$link = 'http://' + settings.address + '/' + short_url.custom_url
		rescue
			short_url = ShortenedUrl.find_by_id(params[:short_url].to_i(36))
			$visitas = Visit.where(:shortened_url_id => short_url.id)
			$link = 'http://' + settings.address + '/' + (short_url.id).to_s
		end
		$url = short_url.url
		$short_url = short_url.id
		haml :visits
end

get '/:shortened' do
	short_url = ShortenedUrl.find_by_custom_url(params[:shortened])
	begin
	short_url.visits << Visit.create(:ip =>  request.ip, :country => request.location.country, :shortened_url_id => short_url.id )
	short_url.save
	redirect short_url.url
	rescue
		short_url = ShortenedUrl.find(params[:shortened].to_i(36))
		short_url.visits << Visit.create(:ip =>  request.ip, :country => request.location.country, :shortened_url_id => short_url.id)
		short_url.save
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

post '/info/:short_url' do 
	country_visits = Visit.where(:country => params[:country], :shortened_url_id => $short_url)
	@result = country_visits.size.to_s
	@country = params[:country]
	haml :visits
end

