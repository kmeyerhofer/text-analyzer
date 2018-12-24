ANALYZE_CHAR_LIMIT = 2500

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

  def json_error(message)
    JSON.generate( {"error": message} )
  end
end

get '/' do
  erb :home
end

post '/api' do
  # require 'pry'; binding.pry
  cleaned_text = clean_text(params[:text_to_analyze].to_s.strip)
  text_to_analyze_length = cleaned_text.size
  if text_to_analyze_length == 0
    json_error('Empty text.')
  elsif text_to_analyze_length >= ANALYZE_CHAR_LIMIT
    json_error("Exceeds #{ANALYZE_CHAR_LIMIT} character limit.")
  elsif params[:analysis_separator] == 'none'
    [InputAnalysis.new(cleaned_text).json]
  else
    separated_text = separate_by(cleaned_text, params[:analysis_separator])
    MultiLineInputAnalysis.new(separated_text).json
  end
end

post '/result' do
  cleaned_text = clean_text(params[:text_to_analyze].to_s.strip)
  text_to_analyze_length = cleaned_text.size

  if text_to_analyze_length == 0
    session[:flash_message] = 'Please input text.'
    redirect to '/'

  elsif text_to_analyze_length >= ANALYZE_CHAR_LIMIT
    session[:flash_message] = "Please input less than #{ANALYZE_CHAR_LIMIT} characters."
    redirect to '/'

  elsif params[:analysis_separator] == 'none'
    input = InputAnalysis.new(cleaned_text)
    @view_data = input.view_elements
    session[:input].unshift(input.session_elements)
    erb :result

  else
    separated_text = separate_by(cleaned_text, params[:analysis_separator])
    input = MultiLineInputAnalysis.new(separated_text)
    @popup_results = input.popup_list_item_strings
    session[:input].unshift(input.list_item_strings.join(''))
    erb :'detailed-result'
  end
end

get '/random' do
  random_result = RandomSentence.new
  input = InputAnalysis.new(random_result.selection, random_result.source, true)
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

get '/api' do
  erb :'api-documentation', :layout => :'extra-info'
end

not_found do
  session[:flash_message] = 'Page not found.'
  redirect to '/'
end
