require 'rake/testtask'
require_relative './lib/create_lexicon.rb'

task :default => [:test]

desc 'Creates needed local lexicon'
task :lexicon do
  lexicon = CreateLexicon.new
end

desc 'Run tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/*_test.rb']
end
