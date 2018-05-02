class DBConnect
  attr_accessor :connect
  def initialize
    @connect = PG.connect(dbname: 'text_analyzer_dev')
  end

  def user_entry(text, result)
    sql = <<~SQL
    INSERT INTO user_entries (phrase, category_id) VALUES
    ($1, (SELECT id FROM categories WHERE name = $2));
    SQL
    connect.exec_params(sql, [text, result])
  end
end
