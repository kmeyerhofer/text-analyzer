ENV["RACK_ENV"] = 'test'
require 'minitest/autorun'
require 'rack/test'
require_relative '../analyzer'

class AnalyzeTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, "Enter text to analyze"
  end

  def test_text_submission
    post '/result', text_to_analyze: 'testing this text'
    assert_equal 200, last_response.status

  end
end
