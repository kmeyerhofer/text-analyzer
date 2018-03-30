require 'nbayes'

class Lexicon
  attr_reader :words

  def initialize
    @words = NBayes::Base.new.load('./data/combined-lexicon.yml')
  end

  def analyze(phrase)
    words.classify(phrase.split(/\s+/)).max_class
  end

  def raw_data(phrase)
    words.classify(phrase.split(/\s+/))
  end
end
