require 'nbayes'

class Lexicon
  attr_reader :words

  def initialize(db_name)
    @words = NBayes::Base.new(db_name)
  end

  def analyze(phrase)
    words.classify(phrase.split(/\s+/)).max_class
  end

  def raw_data(phrase)
    words.classify(phrase.split(/\s+/))
  end
end
