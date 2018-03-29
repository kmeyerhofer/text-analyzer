require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'
require_relative 'lexicon'


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

post '/analyze' do
  @cleaned_up_text = clean_text(params[:text_to_analyze].to_s.strip)
  if @cleaned_up_text.size == 0
    session[:message] = "Please input text."
    status 422
    erb :home
  elsif @cleaned_up_text.size > 500
    session[:message] = "Please input less than 500 characters."
    status 422
    erb :home
  else
    @result = Lexicon.new.analyze(@cleaned_up_text)
    erb :result
  end
end

# get '/result' do
#   @text = @cleaned_up_text
#   # @result = Lexicon.new.analyze(@cleaned_up_text)
#   erb :result
# end
