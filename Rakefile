require 'rubygems'
require 'bundler/setup'

require 'rake/testtask'
Rake::TestTask.new do |t|
  disabled_wrappers = (ENV['DISABLED_WRAPPERS'] || '').split(',').map(&:strip)
  all_tests = FileList['test/**/*_test.rb']
  if disabled_wrappers.any?
    all_tests = all_tests.reject { |f| disabled_wrappers.any? { |w| f.end_with?("wrappers/#{w}_test.rb") } }
  end
  t.test_files = all_tests
end
