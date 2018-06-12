require 'pg'

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
    sql = "SELECT count(DISTINCT phrase) FROM tokens;"
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
    sql = "SELECT count(phrase) FROM tokens;"
    result = ''
    connect { |connection| result = connection.exec(sql).values[0][0].to_i }
    result
  end

  def category_count
    sql = "SELECT count(name) FROM categories;"
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

  def delete_all_tokens
    sql = "DELETE FROM tokens;"
    connect { |connection| connection.connect.exec(sql) }
  end
end
