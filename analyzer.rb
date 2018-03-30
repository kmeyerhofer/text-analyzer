require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'
require_relative './lib/lexicon'


configure do
  enable :sessions
  set :session_secret, 'super secret' #change later
  # set :erb, :escape_html => true
end

helpers do
  def clean_text(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  erb :home
end

post '/result' do
  @cleaned_up_text = clean_text(params[:text_to_analyze].to_s.strip)
  if @cleaned_up_text.size == 0
    session[:message] = "Please input text."
    status 422
    redirect '/'
  elsif @cleaned_up_text.size > 750
    session[:message] = "Please input less than 750 characters."
    status 422
    redirect '/'
  else
    @result = Lexicon.new.analyze(@cleaned_up_text)
    @cssresult = @result == 'positive' ? 'positive' : 'negative'
    erb :result
  end
end
