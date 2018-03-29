require 'nbayes'

class CreateLexicon
  attr_reader :words
  def initialize
    @words = NBayes::Base.new
    create
  end

  def create
    corpus = Dir.entries('./data').select { |file| file.match?(/(pos|neg)/) }
    corpus.each do |file|
      File.open("./data/#{file}").each do |line|
        encoded_line = line.force_encoding(Encoding::ISO_8859_1)
        words.train(encoded_line.split(/\s+/),
        positive_or_negative(file)) unless line.start_with?(';')
      end
    end
    words.dump('./data/combined-lexicon.yml')
  end

  def positive_or_negative(file)
    file.match?(/pos/) ? 'positive' : 'negative'
  end
end
