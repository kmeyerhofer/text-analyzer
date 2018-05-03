require 'rake/testtask'
require_relative './lib/create_lexicon.rb'
require_relative './lib/dbconnect.rb'

task :default => [:test]

desc 'Inserts data into local PostgreSQL database'
task :lexicon do
  db = DBConnect.new
  token_count = db.token_count
  category_count = db.category_count
  if token_count <= 25000 && category_count < '2'
    CreateLexicon.new
  else
    puts "Lexicon already created."
  end
end

desc 'Run tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/*_test.rb']
  t.warning = false
end
