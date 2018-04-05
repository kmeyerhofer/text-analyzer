require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'
require_relative './lib/lexicon'
require_relative './lib/random_sentence'

configure do
  enable :sessions
  set :session_secret, 'super secret'
  disable :show_exceptions
end

before do
  if session[:input].nil?
    session[:input] = []
  elsif session[:input].count > 5
    session[:input].delete_at(-1)
  end
end

helpers do
  def clean_text(text)
    Rack::Utils.escape_html(text)
  end

  def analyze(text)
    Lexicon.new.analyze(text)
  end

  def css(result)
    result == 'positive' ? result : 'negative'
  end

  def form_text
    if session[:text_error]
      session.delete(:text_error)
    end
  end
end

get '/' do
  erb :home
end

post '/result' do
  @cleaned_up_text = clean_text(params[:text_to_analyze].to_s.strip)
  if @cleaned_up_text.size == 0
    session[:message] = "Please input text."
    session[:text_error] = params[:text_to_analyze]
    redirect to '/'
  elsif @cleaned_up_text.size > 750 && @cleaned_up_text.size < 1000
    session[:message] = "Please input less than 750 characters."
    session[:text_error] = @cleaned_up_text
    redirect to '/'
  elsif @cleaned_up_text.size >= 1000
    session[:message] = "Please input text less than 750 characters."
    redirect to '/'
  else
    @result = analyze(@cleaned_up_text)
    @cssresult = css(@result)
    session[:input].unshift(@cleaned_up_text => @cssresult)
    erb :result
  end
end

post '/random' do
  random_result = RandomSentence.new
  @cleaned_up_text = random_result.selection
  @source = random_result.source
  @result = analyze(@cleaned_up_text)
  @cssresult = css(@result)
  erb :result
end

post '/clear' do
  session[:input] = []
  redirect to '/'
end
