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
    text_files = Dir.entries('./data').select { |file| file.match?(/(pos|neg)/) }
    csv_files = Dir.entries('./data').select { |file| file.match?(/\.csv/) }
    text_file_tokens(text_files)
    csv_file_tokens(csv_files)
    end
  end

  def pos_or_neg_file(file)
    file.match?(/pos/) ? 'positive' : 'negative'
  end

  def text_tokens(files)
    files.each do |file|
      positive_or_negative = pos_or_neg_file(file)
      File.open("./data/#{file}").each do |line|
        encoded_line = line.force_encoding(Encoding::ISO_8859_1)
        words.train(encoded_line.split(/\s+/),
          positive_or_negative) unless line.start_with?(';')
      end
    end
  end

  def pos_or_neg_num(num)
    case num
    when '2'
      'positive'
    when '1'
      'negative'
    end
  end

  def csv_file_text(file, row)
    if file.match?(/yelp/)
      row[1]
    elsif file.match?(/amazon/)
      "#{row[1]} #{row[2]}"
    end
  end

  def csv_file_tokens(files)
    files.each do |file|
      CSV.foreach("./data/#{file}") do |row|
        words.train(csv_file_text(file, row).split(/\s+/),
          pos_or_neg_num(row[0])) # row[0] may or may not be a string
      end
    end
  end
end
