require 'nbayes'
require_relative 'dbconnect'

class CreateLexicon
  attr_reader :words
  def initialize
    @words = NBayes::Base.new
    insert_categories
    insert_tokens
  end

  def insert_categories
    db = DBConnect.new
    db.insert_categories('positive', 'negative')
  end

  def insert_tokens
    corpus = Dir.entries('./data').select { |file| file.match?(/(pos|neg)/) }
    corpus.each do |file|
      File.open("./data/#{file}").each do |line|
        encoded_line = line.force_encoding(Encoding::ISO_8859_1)
        words.train(encoded_line.split(/\s+/),
        positive_or_negative(file)) unless line.start_with?(';')
      end
    end
  end

  def positive_or_negative(file)
    file.match?(/pos/) ? 'positive' : 'negative'
  end
end
