class ProcessLexicon
  def initialize(db_name)
    @line_count = 0
    output_line_count
    @words = NBayes::Base.new(db_name)
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

  def pos_or_neg_num(num)
    case num.to_s
    when '2'
      'positive'
    when '1'
      'negative'
    end
  end

  def pos_or_neg_file(file)
    file.match?(/pos/) ? 'positive' : 'negative'
  end

  def output_line_count
    p "Line count: #{@line_count}. Time: #{Time.now}"
  end

  def output_file_message(message, file)
    p "#{message} #{file} at #{Time.now}"
  end

  def csv_file_hash_text(file, row)
    if file.match?(/yelp/)
      row[:comment]
    elsif file.match?(/amazon/)
      "#{row[:title]} #{row[:review]}"
    end
  end

  def csv_file_source(file)
    if file.match?(/yelp/)
      ['category', 'comment',  '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11']
    elsif file.match?(/amazon/)
      ['category', 'title', 'review']
    end
  end

  def csv_parallel_worker(file, chunk_array)
    chunk_array.each do |row|
      @line_count += 1
      begin
        @words.train(csv_file_hash_text(file, row).split(/\s+/),
          pos_or_neg_num(row[:category]))
      rescue => e
        p "Exception caught: #{e}"
        words_to_s = csv_file_hash_text(file, row).to_s
        @words.train(words_to_s.split(/\s+/), pos_or_neg_num(row[:category]))
      end
      output_line_count if @line_count % 1000 == 0
    end
  end

  def smarter_csv_tokens(files, threads = 4)
    files.each do |file|
      output_file_message('Processing file:', file)
      chunks = SmarterCSV.process(file, { chunk_size: 1000, user_provided_headers: csv_file_source(file)})
      Parallel.each(chunks, in_threads: threads) do |chunk|
        csv_parallel_worker(file, chunk)
      end
      output_file_message('Finished processing file:', file)
    end
  end

  def parallel_text_work(file)
    positive_or_negative = pos_or_neg_file(file)
    output_file_message('Processing file:', file)
    File.open(file).each do |line|
      @line_count += 1
      encoded_line = line.force_encoding(Encoding::ISO_8859_1)
      @words.train(encoded_line.split(/\s+/),
        positive_or_negative) unless line.start_with?(';')
      output_line_count if @line_count % 1000 == 0
    end
    output_file_message('Finished processing file:', file)
  end

  def parallel_text_tokens(files)
    Parallel.each(files, in_threads: 4) do |file|
      parallel_text_work(file)
    end
  end

  def text_tokens(files)
    files.each do |file|
      output_file_message('Processing file:', file)
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

  def csv_file_text(file, row)
    if file.match?(/yelp/)
      row[1]
    elsif file.match?(/amazon/)
      "#{row[1]} #{row[2]}"
    end
  end

  def csv_tokens(files)
    files.each do |file|
      output_file_message('Processing file:', file)
      CSV.foreach(file) do |row|
        @line_count += 1
        @words.train(csv_file_text(file, row).split(/\s+/),
        pos_or_neg_num(row[0]))
        output_line_count if @line_count % 1000 == 0
      end
    end
  end
end

class CreateLexicon < ProcessLexicon
  attr_reader :words
  def initialize(db_name)
    super(db_name)
    insert_categories(db_name)
    insert_tokens
  end

  def insert_categories(db_name)
    db = DBConnect.new(db_name)
    db.insert_categories('positive', 'negative')
  end

  def insert_tokens
    parallel_text_tokens(text_files)
  end
end

class AddFileToLexicon < ProcessLexicon
  def initialize(file_name, db_name, threads = 4)
    super(db_name)
    smarter_csv_tokens([file_name], threads)
  end
end
