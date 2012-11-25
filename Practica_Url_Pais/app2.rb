%w(rubygems sinatra haml ipaddr dm-core dm-validations dm-timestamps dm-types dm-migrations uri rest-client xmlsimple).each  { |lib| require lib}
require 'geocoder'


set :database, 'sqlite3:///shortened_urls.db'
set :address, 'localhost:4567'
#set :address, 'exthost.etsii.ull.es:4567'

DataMapper.setup(:default,"sqlite3:///shortened_urls.db")

class ShortenedUrl 
  include DataMapper::Resource
  
  property :id,				Serial
  property :url,			String
  property :custom_url,		String
  
  has n, :visits
  
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

class Visit 
	include DataMapper::Resource
	
	property :id,			Serial
	property :ip,			String
	property :country,		String
	
	belongs_to :shortened_url
end

DataMapper.auto_upgrade!

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
['/info/:short_url'].each do |path|
	get path do
		short_url = ShortenedUrl.first(:custom_url => params[:short_url])
		begin
			@visitas = []
			short_url.visit.each do |element|
				@visitas.push([element.id, element.country])
			end
		rescue
			visits = ShortenedUrl.first(:id => params[:short_url].to_i(36))
			@visitas = []
			short_url.visit.each do |element|
				@visitas.push([element.id, element.country])
			end
		end
		haml :visits
	end
end

get '/:shortened' do
	short_url = ShortenedUrl.find_by_custom_url(params[:shortened])
	begin
	short_url.visits << Visit.create(:ip =>  request.ip, :country => request.location.country )
	short_url.save
	redirect short_url.url
	rescue
		short_url = ShortenedUrl.find(params[:shortened].to_i(36))
		short_url.visits << Visit.create(:ip =>  request.ip, :country => request.location.country)
		short_url.save
		"URL: #{short_url.url}"
		"IP: #{short_url.visits.methods()}"
		#"Country: #{Visit.country}"
		 
		#redirect short_url.url
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



