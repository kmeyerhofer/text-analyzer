require 'pg'

class DBConnect
  attr_accessor :connect

  def self.db_exists?(db_name)
    PG.connect(dbname: db_name)
  rescue PG::ConnectionBad => e
    false
  end

  @@db_name = ENV['DATABASE_NAME']
  @@connect = self.db_exists?(@@db_name)


  def user_entry_count
    sql = "SELECT count(phrase) FROM user_entries;"
    @@connect.exec(sql).values[0][0].to_i
  end

  def user_entry(text, result, pos_percent, neg_percent)
    sql = <<~SQL
    INSERT INTO user_entries (phrase, category_id, positive_percent, negative_percent) VALUES
    ($1, (SELECT id FROM categories WHERE name = $2), $3, $4);
    SQL
    @@connect.exec_params(sql, [text, result, pos_percent, neg_percent])
  end

  def distinct_token_count
    sql = "SELECT count(DISTINCT phrase) FROM tokens;"
    @@connect.exec(sql).values[0][0].to_i
  end

  def categories
    sql = "SELECT name FROM categories;"
    @@connect.exec(sql).values.flatten
  end

  def token_count
    sql = "SELECT count(phrase) FROM tokens;"
    @@connect.exec(sql).values[0][0].to_i
  end

  def category_count
    sql = "SELECT count(name) FROM categories;"
    @@connect.exec(sql).values[0][0].to_i
  end

  def insert_categories(*categories)
    categories.each do |category|
      sql = <<~SQL
      INSERT INTO categories (name) VALUES ($1)-- ON CONFLICT (name) DO NOTHING;
      SQL
      begin
        @@connect.exec_params(sql, [category])
      rescue PG::UniqueViolation => e
        category
      end
    end
  end

  def delete_all_tokens
    sql = "DELETE FROM tokens;"
    @@connect.exec(sql)
  end
end
