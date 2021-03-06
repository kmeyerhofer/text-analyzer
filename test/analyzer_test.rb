ENV["RACK_ENV"] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'pg'
require_relative '../text_analyzer'


class AnalyzeTest < Minitest::Test
  include Rack::Test::Methods

  def db_name
    ENV['TEXT_ANALYZER_SPEED_DATABASE']
  end

  def db_connect
    DBConnect.new(db_name)
  end

  def connection
    PG.connect(dbname: db_name)
  end

  def setup
    @time = Time.now
    @phrase = ''
  end

  def teardown
    remove_from_db(@phrase)
  end

  def remove_from_db(phrase)
    year = @time.year
    month = @time.month
    day = @time.day
    hour = @time.hour
    min = @time.min
    sql = <<~SQL
    DELETE FROM user_entries WHERE phrase = $1 AND
    EXTRACT(YEAR FROM date) = $2 AND
    EXTRACT(MONTH FROM DATE) = $3 AND
    EXTRACT(DAY FROM DATE) = $4 AND
    EXTRACT(HOUR FROM DATE) = $5 AND
    EXTRACT(MINUTE FROM DATE) = $6;
    SQL
    connection.exec_params(sql, [phrase, year, month, day, hour, min])
  end

  def app
    Sinatra::Application
  end

  def session
    last_request.env['rack.session']
  end

  def test_index
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, "Input text to analyze"
  end

  def test_text_analyze_negative
    post '/result', text_to_analyze: @phrase = 'testing this text',
      analysis_separator: 'none'
    assert_equal 200, last_response.status
    assert_includes last_response.body, @phrase
    assert_includes last_response.body, "Negative"
  end

  def test_text_analyze_positive
    post '/result', text_to_analyze: @phrase = 'testing',
      analysis_separator: 'none'
    assert_equal 200, last_response.status
    assert_includes last_response.body, @phrase
    assert_includes last_response.body, "Positive"
  end

  def test_api_route_returns_result
    post '/api', text_to_analyze: @phrase = 'test', analysis_separator: 'none'
    assert_equal 200, last_response.status
    assert_includes last_response.body, @phrase
    assert_includes last_response.body, 'negative'
  end

  def test_no_text_error
    post '/result', text_to_analyze: '', analysis_separator: 'none'
    assert_equal 302, last_response.status
    assert_equal 'Please input text.', session[:flash_message]
  end

  def test_too_long_text_error
    text = "#{'abcdefghij' * 760}"
    post '/result', text_to_analyze: text, analysis_separator: 'none'
    assert_equal 302, last_response.status
    assert_equal 'Please input less than 2000 characters.',
      session[:flash_message]
  end

  def test_page_not_found
    get '/anythingbutthistest'
    assert_equal 'Page not found.', session[:flash_message]
  end

  def test_successful_random_page
    get '/random'
    assert_equal 200, last_response.status
  end

  def test_recent_entries_with_result_class_negative
    @phrase = 'wheat' # negative
    post '/result', text_to_analyze: @phrase, analysis_separator: 'none'
    assert_includes last_response.body, 'Negative'
  end

  def test_database_categories
    assert_equal ['positive', 'negative'], db_connect.categories
  end

  def test_database_token_count
    db_tokens = connection.exec(
      'SELECT count(DISTINCT phrase) FROM tokens')[0]['count']
    assert_equal db_tokens.to_i, db_connect.distinct_token_count
  end

  def test_database_category_count
    db_categories = connection.exec('SELECT count(*) FROM categories')[0]['count']
    assert_equal db_categories.to_i, db_connect.category_count
  end
end
