require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require_relative './lib/lexicon'
require_relative './lib/random_sentence'
require_relative './lib/dbconnect'


require 'pry'
configure do
  enable :sessions
  set :session_secret, ENV["SESSION_SECRET"]
  # disable :show_exceptions
end

before do
  if session[:input].nil?
    session[:input] = []
  elsif session[:input].count > 5
    session[:input].delete_at(-1)
  end

  @lexicon = Lexicon.new(db_name)
end

helpers do
  def db_name
    ENV["DATABASE_NAME"]
  end

  def clean_text(text)
    Rack::Utils.escape_html(text)
  end

  def css(result)
    max_value = result.values.max
    max_result = result.key(max_value)
    max_result == 'positive' ? max_result : 'negative'
  end

  def save_user_entry(text, result)
    db = DBConnect.new(db_name)
    db.user_entry(text, result)
  end

  def format_percent(value)
    format("%.3f", (value * 100))
  end
end

get '/' do
  erb :home
end

post '/result' do
  # binding.pry
  @cleaned_up_text = clean_text(params[:text_to_analyze].to_s.strip)
  if @cleaned_up_text.size == 0
    session[:flash_message] = 'Please input text.'
    redirect to '/'

  elsif params[:text_to_analyze].size >= 750
    session[:flash_message] = 'Please input less than 750 characters.'
    redirect to '/'

  elsif params[:analysis_type] == 'all_text'
    @result = @lexicon.raw_data(@cleaned_up_text)
    @cssresult = css(@result)
    @positive_percent = "#{format_percent(@result['positive'])}%"
    @negative_percent = "#{format_percent(@result['negative'])}%"
    session[:input].unshift(@cleaned_up_text =>
      [@cssresult, @positive_percent, @negative_percent])
    save_user_entry(params[:text_to_analyze], @cssresult)
    erb :result

  elsif params[:analysis_type] == 'punctuation_delimiter'
    @result = @lexicon.raw_data(@cleaned_up_text)
    @punctuation_separated_text = @cleaned_up_text.split(/,|\.|!|\?|"|'|;|:/)
    @separated_results = {}
    # binding.pry
    @punctuation_separated_text.each do |phrase|
      @separated_results[phrase] = @lexicon.raw_data(phrase)
    end
    erb :'detailed-result'

  elsif params[:analysis_type] == 'new_line'
    @result = @lexicon.raw_data(@cleaned_up_text)
    @new_line_separated_text = @cleaned_up_text.split(/\n/)
    @separated_results = {}
    @new_line_separated_text.each do |phrase|
      @separated_results[phrase] = @lexicon.raw_data(phrase)
    end
    erb :'detailed-result'
  end
end

post '/random' do
  random_result = RandomSentence.new
  @cleaned_up_text = random_result.selection
  @text_source = random_result.source
  @result = analyze(@cleaned_up_text)
  @cssresult = css(@result)
  erb :result
end

post '/clear' do
  session[:input] = []
  redirect to '/'
end

not_found do
  session[:flash_message] = 'Page not found.'
  redirect to '/'
end
