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

  def token_count
    sql = "SELECT count(phrase) FROM tokens;"
    connect.exec(sql).values[0][0].to_i
  end

  def category_count
    sql = "SELECT count(name) FROM categories;"
    connect.exec(sql).values[0][0].to_i
  end
end
