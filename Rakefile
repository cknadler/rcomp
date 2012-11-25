require 'cucumber/rake/task'
require 'bundler/gem_tasks'

desc "Run features"
Cucumber::Rake::Task.new(:features)

desc "Clean"
task :clean do
  rm_rf "pkg"
end

task :default => :features
