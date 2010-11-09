require 'rake'
require 'rspec/core/rake_task'


task :test => [:model_test, :view_test]

desc "Run model tests"
RSpec::Core::RakeTask.new(:model_test) do |t|
  t.pattern = './test/model/*.rb'
end

desc "Run View Tests"
RSpec::Core::RakeTask.new(:view_test) do |t|
  t.pattern = './test/view/*.rb'
end

