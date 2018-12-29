class CreateLexicon
  attr_reader :words
  def initialize(db_name)
    @line_count = 0
    output_line_count
    @words = NBayes::Base.new(db_name)
    insert_categories(db_name)
    insert_tokens
  end

  def insert_categories(db_name)
    db = DBConnect.new(db_name)
    db.insert_categories('positive', 'negative')
  end

  def find_files(regex)
    files = Dir.entries('./data').select { |file| file.match?(regex) }
    files.map { |file| File.expand_path(file, './data') }
  end

  def text_files
    find_files(/(pos|neg)/)
  end

  def csv_files
    find_files(/\.csv/)
  end

  def insert_tokens
    text_tokens(text_files)
    csv_tokens(csv_files)
  end

  def pos_or_neg_file(file)
    file.match?(/pos/) ? 'positive' : 'negative'
  end

  def output_line_count
    p "Line count: #{@line_count}. Time: #{Time.now}"
  end

  def output_file_in_use(file)
    p "Reading file #{file}"
  end

  def text_tokens(files)
    files.each do |file|
      output_file_in_use(file)
      positive_or_negative = pos_or_neg_file(file)
      File.open(file).each do |line|
        @line_count += 1
        encoded_line = line.force_encoding(Encoding::ISO_8859_1)
        @words.train(encoded_line.split(/\s+/),
          positive_or_negative) unless line.start_with?(';')
        output_line_count if @line_count % 1000 == 0
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

  def csv_tokens(files)
    files.each do |file|
      output_file_in_use(file)
      CSV.foreach(file) do |row|
        @line_count += 1
        @words.train(csv_file_text(file, row).split(/\s+/),
          pos_or_neg_num(row[0]))
        output_line_count if @line_count % 1000 == 0
      end
    end
  end
end
