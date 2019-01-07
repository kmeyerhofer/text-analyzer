require 'rake/testtask'
require 'nbayes'
require 'pry'
require 'csv'
require 'smarter_csv'
require 'parallel'
require_relative './lib/process_lexicon.rb'
require_relative './lib/dbconnect.rb'

task :default => [:test]

def db_name
  ENV['DATABASE_NAME']
end

def set_db
  DBConnect.new(db_name)
end

desc 'Initial insertion of data into local PostgreSQL database.'
task :create_lexicon do
  db = set_db
  if db.connect && (db.token_count < 1 && db.category_count < 1)
    CreateLexicon.new(db_name)
  else
    puts "Lexicon already created."
  end
end

desc 'Stats of current text-analyzer database.'
task :stats do
  db = set_db
  puts <<~STATS
  Distinct Tokens:  #{db.distinct_token_count}
  Token Count:      #{db.token_count}
  Category Count:   #{db.category_count}
  User Entry Count: #{db.user_entry_count}
  STATS
end

desc 'Pass a single filename ("/path/to/file") to add to the lexicon database.'
task :insert_tokenfile do
  argument = ARGV[1..ARGV.length - 1]
  if argument.length < 1
    puts "Please pass a filename argument."
  elsif argument.length == 2
    if argument[0].class != String
      puts "Argument must be a string"
    elsif File.exist?(argument[0])
      if argument[1]
        AddFileToLexicon.new(argument[0], db_name, argument[1].to_i)
      else
        AddFileToLexicon.new(argument[0], db_name)
      end
    else
      puts "File does not exist."
    end
  else
    puts "Command only takes one filename argument."
  end
end

desc 'Adds minimum tokens to database.'
task :add_minimum_tokens do
  AddMinimumTokens.new(db_name)
end

desc 'Deletes current tokens and re-adds them to database.'
task :reinsert_minimum_tokens do
  db = set_db
  db.delete_all_tokens
  CreateLexicon.new(db_name)
end

desc 'Creates and/or updates the token_stats database table'
task :token_stats_table do
  db = set_db
  db.create_token_stats
  db.insert_token_stats
end

desc 'Run tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/*_test.rb']
  t.warning = false
end
