require 'nbayes'

class Lexicon
  attr_reader :words

  #assume_uniform makes analysis compute as if the categories were equal sizes
  @@words = NBayes::Base.new(assume_uniform: false)

  def analyze(phrase)
    @@words.classify(phrase.split(/\s+/)).max_class
  end

  def raw_data(phrase)
    @@words.classify(phrase.split(/\s+/))
  end
end
