require_relative './dbconnect'
require_relative './lexicon'

class InputAnalysis
  attr_reader :cleaned_text, :lexicon, :analysis_result, :random_text_source,
              :positive_percent, :negative_percent, :background_css_class

  def initialize(cleaned_text, text_source = nil)
    @cleaned_text = cleaned_text
    @lexicon = Lexicon.new
    @random_text_source = text_source
    @analysis_result = text_analysis
    @positive_percent, @negative_percent = format_percent
    @background_css_class = css_class
    save_user_entry
  end

  def save_user_entry
    db = DBConnect.new
    db.user_entry(
      cleaned_text, background_css_class, positive_percent, negative_percent
    )
  end

  def session_elements
    format_list_item_string(results_hash)
  end

  def results_hash
    {cleaned_text => [positive_percent, negative_percent, background_css_class]}
  end

  def view_elements
    view_data = {}
    view_data[:cleaned_up_text] = cleaned_text
    view_data[:css_result] = background_css_class
    view_data[:positive_percent] = positive_percent
    view_data[:negative_percent] = negative_percent
    view_data[:text_source] = random_text_source

    view_data
  end

  private

  def format_list_item_string(results_hash)
    array = []
    results_hash.each_pair do |phrase, data|
      array << "<span class=\"#{data[2]}\" title=\"#{data[0]} positive, #{data[1]} negative\">#{phrase}</span>"
    end
    array.unshift("<li>")
    array.push("</li>")
    array.join('')
  end

  def text_analysis
    lexicon.raw_data(cleaned_text)
  end

  def css_class
    max_value = analysis_result.values.max
    max_result = analysis_result.key(max_value)
    max_result == 'positive' ? max_result : 'negative'
  end

  def format_percent
    analysis_result.values.map { |num| format("%.3f", (num * 100)) + '%' }
  end

  def db_name
    ENV['DATABASE_NAME']
  end
end
