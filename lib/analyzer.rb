ANALYZE_CHAR_LIMIT = 2000

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
    elsif param == 'punctuation'
      cleaned_text.split(/(?<=[?.!,])/)
    end
  end

  def json_error(message)
    JSON.generate( {"error": message} )
  end

  def request_category(text_length, analysis_separator)
    if text_length == 0
      'empty text'
    elsif text_length > ANALYZE_CHAR_LIMIT
      'text too long'
    elsif analysis_separator == 'none'
      'no separation'
    elsif analysis_separator == 'punctuation' || analysis_separator == 'new_line'
      'separation'
    else
      'error'
    end
  end

  def process_params
    result = []
    result.push(params[:analysis_separator])
    result.push(clean_text(params[:text_to_analyze].to_s.strip))
    result.push(params[:text_to_analyze].size)
    result
  end

  def db_to_use
    if params[:analysis_focus] == 'accuracy'
      ENV['TEXT_ANALYZER_ACCURACY_DATABASE']
    else
      ENV['TEXT_ANALYZER_SPEED_DATABASE']
    end
  end
end

get '/' do
  erb :'vue-home'
end

post '/api' do
  content_type 'application/json'
  analysis_separator, cleaned_text, text_to_analyze_length = process_params
  category = request_category(text_to_analyze_length, analysis_separator)
  case category
  when 'empty text'
    json_error('Empty text.')
  when 'text too long'
    json_error("Exceeds #{ANALYZE_CHAR_LIMIT} character limit.")
  when 'no separation'
    [InputAnalysis.new(db_to_use, cleaned_text).json]
  when 'separation'
    separated_text = separate_by(cleaned_text, analysis_separator)
    MultiLineInputAnalysis.new(db_to_use, separated_text).json
  when 'error'
    json_error('Invalid separator value.')
  end
end

post '/result' do
  analysis_separator, cleaned_text, text_to_analyze_length = process_params
  category = request_category(text_to_analyze_length, analysis_separator)
  case category
  when 'empty text'
    session[:flash_message] = 'Please input text.'
    redirect to '/'
  when 'text too long'
    session[:flash_message] = "Please input less than #{ANALYZE_CHAR_LIMIT} characters."
    redirect to '/'
  when 'no separation'
    input = InputAnalysis.new(db_to_use, cleaned_text)
    @view_data = input.view_elements
    session[:input].unshift(input.session_elements)
    erb :result
  when 'separation'
    separated_text = separate_by(cleaned_text, analysis_separator)
    input = MultiLineInputAnalysis.new(db_to_use, separated_text)
    @popup_results = input.popup_list_item_strings
    session[:input].unshift(input.list_item_strings.join(''))
    erb :'detailed-result'
  when 'error'
    session[:flash_message] = 'An error occurred, please try again.'
    redirect to '/'
  end
end

get '/random' do
  random_result = RandomSentence.new
  input = InputAnalysis.new(db_to_use, random_result.selection, random_result.source, true)
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
