require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require_relative './lib/random_sentence'
require_relative './lib/input_analysis'
require_relative './lib/multi_line_input_analysis'


# require_relative '../nbayes-fork/lib/nbayes'


require 'pry'
configure do
  enable :sessions
  set :session_secret, ENV["SESSION_SECRET"]
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
    Rack::Utils.escape_html(text).gsub(/\r/, '')
  end

  def separate_by(cleaned_text, param)
    if param == 'new_line'
      cleaned_text.split(/\n/)
    else
      cleaned_text.split(/(?<=[?.!,])/)
    end
  end
end

get '/' do
  erb :home
end

post '/result' do
  cleaned_text = clean_text(params[:text_to_analyze].to_s.strip)
  text_to_analyze_length = cleaned_text.size

  if text_to_analyze_length == 0
    session[:flash_message] = 'Please input text.'
    redirect to '/'

  elsif text_to_analyze_length >= 750
    session[:flash_message] = 'Please input less than 750 characters.'
    redirect to '/'

  elsif params[:analysis_type] == 'all_text'
    input = InputAnalysis.new(cleaned_text)
    @view_data = input.view_elements
    session[:input].unshift(input.session_elements)
    erb :result

  else
    separated_text = separate_by(cleaned_text, params[:analysis_type])
    input = MultiLineInputAnalysis.new(separated_text)
    @popup_results = input.popup_list_item_strings
    session[:input].unshift(input.list_item_strings.join(''))
    erb :'detailed-result'
  end
end

get '/random' do
  random_result = RandomSentence.new
  input = InputAnalysis.new(random_result.selection, random_result.source)
  @view_data = input.view_elements
  erb :result
end

post '/clear' do
  session[:input] = []
  redirect to '/'
end

get '/learn-more' do
  erb :'learn-more', :layout => :'extra-info'
end

get '/citations' do
  erb :citations, :layout => :'extra-info'
end

get '/privacy-policy' do
  erb :'privacy-policy', :layout => :'extra-info'
end

not_found do
  session[:flash_message] = 'Page not found.'
  redirect to '/'
end
