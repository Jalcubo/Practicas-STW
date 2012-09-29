require 'sinatra'
require 'erb'
require 'haml'

# before we process a route we'll set the response as plain text
# and set up an array of viable moves that a player (and the
# computer) can perform
before do
  @defeat = { rock: :scissors, paper: :rock, scissors: :paper}
  @throws = @defeat.keys
end

get '/' do
	$cont_player ||= 0
	$cont_comp ||= 0
	haml :index
  # renders views/index.erb
end

get '/reset' do
	$cont_player = 0
	$cont_comp = 0
	redirect "/"
end

post '/throw' do
	@opcion = params[:op]
	redirect "/throw/#{@opcion}"
end
get '/throw/:type' do
  # the params hash stores querystring and form data
  @player_throw = params[:type].to_sym

  halt(403, "You must throw one of the following: '#{@throws.join(', ')}'") unless @throws.include? @player_throw

  @computer_throw = @throws.sample
  @img_comp = "/img/#{@computer_throw}.jpg"
  @img_player = "/img/#{@player_throw}.jpg"

  if @player_throw == @computer_throw 
	
    @answer = "There is a tie"
    haml :result
  elsif @player_throw == @defeat[@computer_throw]
    @answer = "Computer wins; #{@computer_throw} defeats #{@player_throw}"
	$cont_comp = $cont_comp + 1;
    haml :result
  else
    @answer = "Well done. #{@player_throw} beats #{@computer_throw}"
	$cont_player = $cont_player + 1;
    haml :result
  end
end
