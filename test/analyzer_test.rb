ENV["RACK_ENV"] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'pg'
require_relative '../analyzer'

class AnalyzeTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # def setup
  #   # Dir.entries('./data').include?('combined-lexicon.yml')
  # end

  def session
    last_request.env['rack.session']
  end

  def test_index
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, "Enter text to analyze"
  end

  def test_text_analyze_negative
    post '/result', text_to_analyze: 'testing this text'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'testing this text'
    assert_includes last_response.body, "Negative"
  end

  def test_text_analyze_positive
    post '/result', text_to_analyze: 'testing'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'testing'
    assert_includes last_response.body, "Positive"
  end

  def test_no_text_error
    post '/result', text_to_analyze: '   '
    assert_equal 302, last_response.status
    assert_equal 'Please input text.', session[:message]
  end

  def test_too_long_text_error
    text = "#{'abcdefghij' * 76}"
    post '/result', text_to_analyze: text
    assert_equal 302, last_response.status
    assert_equal 'Please input less than 750 characters.', session[:message]
  end

  def test_successful_random_page
    post '/random'
    assert_equal 200, last_response.status
  end

  def test_recent_entries
    text1 = "the train to denver" # positive
    text2 = "you missed it!" # negative
    post '/result', text_to_analyze: text1
    post '/result', text_to_analyze: text2
    get '/'
    assert_includes last_response.body, text1
    assert_includes last_response.body, text2
  end

  def test_clear_recent_entries
    text1 = "the train to denver" # positive
    text2 = "you missed it!" # negative
    post '/result', text_to_analyze: text1
    post '/result', text_to_analyze: text2
    get '/'
    assert_includes last_response.body, text1
    assert_includes last_response.body, text2
    post '/clear'
    refute_includes last_response.body, text1
    refute_includes last_response.body, text2
  end

  def test_database_categories
    test = Lexicon.new
    assert_equal ['positive', 'negative'], test.words.data.data.keys
  end

  def test_database_token_count
    test = Lexicon.new
    connection = PG.connect(dbname: 'text_analyzer_dev')

    db_tokens = connection.exec('SELECT count(*) FROM tokens')[0]['count']
    assert_equal db_tokens.to_i, test.words.vocab.tokens.count
  end

  def test_database_category_count
    test = Lexicon.new
    connection = PG.connect(dbname: 'text_analyzer_dev')
    db_categories = connection.exec('SELECT count(*) FROM categories')[0]['count']
    assert_equal db_categories.to_i, test.words.data.data.keys.count
  end
end
