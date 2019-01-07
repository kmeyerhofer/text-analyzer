class DBConnect
  attr_accessor :db_name

  def initialize(db_name)
    @db_name = db_name
  end

  def connect
    connection = db_exists?
    yield connection
    connection.finish
  end

  def db_exists?
    PG.connect(dbname: db_name)
  rescue PG::ConnectionBad => e
    false
  end

  def user_entry_count
    sql = "SELECT count(phrase) FROM user_entries;"
    result = ''
    connect { |connection| result = connection.exec(sql).values[0][0].to_i }
    result
  end

  def user_entry(text, result, pos_percent, neg_percent)
    sql = <<~SQL
    INSERT INTO user_entries (phrase, category_id, positive_percent, negative_percent) VALUES
    ($1, (SELECT id FROM categories WHERE name = $2), $3, $4);
    SQL
    connect do |connection|
      connection.exec_params(sql, [text, result, pos_percent, neg_percent])
    end
  end

  def distinct_token_count
    sql = "SELECT value FROM token_stats WHERE name = 'distinct_token_count';"
    result = ''
    connect { |connection| result = connection.exec(sql).values[0][0].to_i }
    result
  end

  def categories
    sql = "SELECT name FROM categories;"
    result = ''
    connect { |connection| result = connection.exec(sql).values.flatten }
    result
  end

  def token_count
    sql = "SELECT value FROM token_stats WHERE name = 'total_token_count';"
    result = ''
    connect { |connection| result = connection.exec(sql).values[0][0].to_i }
    result
  end

  def category_count
    sql = "SELECT value FROM token_stats WHERE name = 'category_count';"
    result = ''
    connect { |connection| result = connection.exec(sql).values[0][0].to_i }
    result
  end

  def insert_categories(*categories)
    categories.each do |category|
      sql = <<~SQL
      INSERT INTO categories (name) VALUES ($1)-- ON CONFLICT (name) DO NOTHING;
      SQL
      begin
        connect { |connection| connection.exec_params(sql, [category]) }
      rescue PG::UniqueViolation => e
        category
      end
    end
  end

  def create_token_stats
    drop_table = "DROP TABLE token_stats;"
    sql = <<-SQL
    CREATE TABLE token_stats (
      id serial PRIMARY KEY,
      name varchar(30) NOT NULL,
      value int NOT NULL,
      category_id int,
      FOREIGN KEY (category_id) REFERENCES categories(id)
    );
    SQL
    connect do |connection|
      begin
        connection.exec(drop_table)
      rescue PG::UndefinedTable => e
      ensure
        connect { |connection| connection.exec(sql) }
      end
    end
  end

  def insert_token_stats
    general_stats = <<-SQL
    INSERT INTO token_stats (name, value) VALUES
    ('distinct_token_count', (SELECT count(DISTINCT phrase) FROM tokens)),
    ('total_token_count', (SELECT count(phrase) FROM tokens)),
    ('category_count', (SELECT count(name) FROM categories));
    SQL
    connect { |connection| connection.exec(general_stats) }
    categories.each do |category|
      category_id = "(SELECT id FROM categories WHERE name = '#{category}')"
      sql = <<-SQL
      INSERT INTO token_stats (name, value, category_id) VALUES
      ('token_frequency_count', (SELECT sum(frequency) FROM tokens WHERE category_id = #{category_id}), #{category_id}),
      ('token_count', (SELECT count(phrase) FROM tokens WHERE category_id = #{category_id}), #{category_id});
      SQL
      connect { |connection| connection.exec(sql) }
    end
    puts 'Token stats added.'
  end

  def delete_all_tokens
    sql = "DELETE FROM tokens;"
    connect { |connection| connection.exec(sql) }
  end
end
