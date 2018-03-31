class RandomSentence
  attr_accessor :selection, :source
  def initialize
    @selection = random_sentence
  end

  def random_sentence
    file_array = sample_files
    lines_array = []
    File.open(file_array).each do |line|
      if file_array.include?('random-statements-ls.txt')
        lines_array << line
        self.source = "\'Introduction to Programming with Ruby\'\nCopyright \u00a9 2018 Launch School"
      else
        lines_array << line
      end
    end
    lines_array.sample
  end

  def sample_files
    ['./data/random-statements-ls.txt',
      './data/random-statements-misc.txt'].sample
  end
end
