ENV["RACK_ENV"] = 'test'
require 'minitest/autorun'
require 'rack/test'
require_relative '../analyzer'

class AnalyzeTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    Dir.entries('./data').include?('combined-lexicon.yml')
  end

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
    post '/result', text_to_analyze: 'happy bugs'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'happy bugs'
    assert_includes last_response.body, "Positive"
  end

  def test_no_text_error
    post '/result', text_to_analyze: '   '
    assert_equal 302, last_response.status
    assert_equal 'Please input text.', session[:message]
    get '/'
    assert_includes last_response.body, ">   </textarea>"
  end

  def test_too_long_text_error
    text = "#{'abcdefghij' * 76}"
    post '/result', text_to_analyze: text
    assert_equal 302, last_response.status
    assert_equal 'Please input less than 750 characters.', session[:message]
    get '/'
    assert_includes last_response.body, ">#{text}</textarea>"
  end
end
