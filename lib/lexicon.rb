require 'nbayes'

class Lexicon
  attr_reader :words

  #assume_uniform makes analysis compute as if the categories were equal sizes
  @@words = NBayes::Base.new(assume_uniform: false)

  # regex matches any non-word character except " ' ".
  def analyze(phrase)
    @@words.classify(phrase.split(/[^\w']/)).max_class
  end

  def raw_data(phrase)
    @@words.classify(phrase.split(/[^\w']/))
  end
end
