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

def analyze(text)
  Lexicon.new.analyze(text)
end

def random_result
  line_array = []
  File.open('data/random-queries.txt').each { |line| line_array << line }
  line_array.sample
end

def css(result)
  result == 'positive' ? 'positive' : 'negative'
end

get '/' do
  @previous_input = session.delete(:input) unless session[:input].nil?
  erb :home
end

post '/result' do
  @cleaned_up_text = clean_text(params[:text_to_analyze].to_s.strip)
  if @cleaned_up_text.size == 0
    session[:message] = "Please input text."
    session[:input] = params[:text_to_analyze]
    redirect '/'
  elsif @cleaned_up_text.size > 750
    session[:message] = "Please input less than 750 characters."
    session[:input] = @cleaned_up_text
    redirect '/'
  else
    @result = analyze(@cleaned_up_text)
    @cssresult = css(@result)
    erb :result
  end
end

post '/random' do
  @cleaned_up_text = random_result
  @result = analyze(@cleaned_up_text)
  @cssresult = css(@result)
  erb :result
end
