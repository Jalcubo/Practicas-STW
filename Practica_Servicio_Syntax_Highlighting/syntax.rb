require 'sinatra'
require 'syntaxi'

class String
  def formatted_body(lenguaje)
    source = %Q{
				[code lang= '#{lenguaje}']
					#{self}
				[/code]
				}
    html = Syntaxi.new(source).process
    %Q{
      <div class="syntax syntax_#{lenguaje}">
        #{html}
      </div>
    }
  end
end

get '/' do
  erb :new
end

post '/' do
	@lenguaje = params[:lenguaje]
	@text = params[:body].formatted_body(@lenguaje)
	erb :result
end
