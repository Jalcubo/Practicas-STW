# coding: utf-8
require 'sinatra'
set server: 'thin', connections: []

get '/' do
  halt erb(:login) unless params[:user]
  erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
end

get '/stream', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    out.callback { settings.connections.delete(out) }
  end
end

post '/' do
  settings.connections.each { |out| out << "data: #{params[:msg]}\n\n" }
  204 # response without entity body
end

__END__

@@ layout
<html>
  <head> 
    <title>Super Simple Chat with Sinatra</title> 
    <meta charset="utf-8" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script> 
  </head> 
  <body><%= yield %></body>
</html>

@@ login
<form action='/'>
  <label for='user'>User Name:</label>
  <input name='user' value='' />
  <input type='submit' value="GO!" />
</form>

@@ chat
<pre id='chat'></pre>

<script>
  // reading
  var es = new EventSource('/stream');
  es.onmessage = function(e) {
  var aux;
    if (aux = e.data.match(/<%= user %>: \/(.+): (.+)/)){
      $('#chat').append("Mensaje Enviado a " + aux[1] + ": " + aux[2] + "\n");
    } else if (aux = e.data.match(/(.+)\/<%= user %>:(.+)/)) {
      $('#chat').append("Mensaje Recibido de " + aux[1] + aux[2] + "\n");
    } else if (!e.data.match(/(.+): \/(.+):/)) {
      $('#chat').append(e.data + "\n");
    }
  };
  // writing
  $("form").live("submit", function(e) {
    $.post('/', {msg: "<%= user %>: " + $('#msg').val()});
    $('#msg').val(''); $('#msg').focus();
    e.preventDefault();
  });
</script>

<form>
  <input id='msg' placeholder='type message here...' />
</form>