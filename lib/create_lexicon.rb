require 'nbayes'
require_relative 'dbconnect'

class CreateLexicon
  attr_reader :words
  def initialize(db_name)
    @words = NBayes::Base.new(db_name)
    insert_categories(db_name)
    insert_tokens
  end

  def insert_categories(db_name)
    db = DBConnect.new(db_name)
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
