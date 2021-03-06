class MultiLineInputAnalysis
  attr_accessor :separated_results, :list_item_strings,
                :popup_list_item_strings

  def initialize(db_name, cleaned_separated_text)
    @list_item_strings = []
    @popup_list_item_strings = []
    @separated_results = []
    @json_results = []
    iterate_through_phrases(db_name, cleaned_separated_text)
  end

  def iterate_through_phrases(db_name, cleaned_separated_text)
    cleaned_separated_text.each do |phrase|
      result = InputAnalysis.new(db_name, phrase)
      @json_results.push(result)
      self.popup_list_item_strings << format_popup_list_items(result)
      self.list_item_strings << format_multi_list_item_string(result.results_hash)
      self.separated_results.push(result.results_hash)
    end
    self.list_item_strings.unshift("<li>")
    self.list_item_strings.push("</li>")
  end

  def format_popup_list_items(analysis_object)
    "<div class=\"relative-parent\">
      <li class=\"#{analysis_object.background_css_class}\"
          title=\"#{analysis_object.positive_percent} positive, #{analysis_object.negative_percent} negative\">
        #{analysis_object.cleaned_text}
      </li>
      <div class=\"popup\">
        <span class=\"popup-positive\">
          #{analysis_object.positive_percent}
        </span><!--
     --><span class=\"popup-negative\">
          #{analysis_object.negative_percent}
        </span>
      </div>
    </div>"
  end

  def format_multi_list_item_string(results_hash)
    array = []
    results_hash.each_pair do |phrase, data|
      array << "<span class=\"#{data[2]}\" title=\"#{data[0]} positive, #{data[1]} negative\">#{phrase}</span>"
    end
    array
  end

  def json
    results = @json_results.map do |text_entry|
      text_entry.view_elements
    end
    JSON.generate(results)
  end
end
