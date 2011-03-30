require 'rubygems'

begin
  require 'bundler'
rescue LoadError => e
  STDERR.puts e.message
  STDERR.puts "Run `gem install bundler` to install Bundler."
  exit e.status_code
end

begin
  Bundler.setup(:development)
rescue Bundler::BundlerError => e
  STDERR.puts e.message
  STDERR.puts "Run `bundle install` to install missing gems."
  exit e.status_code
end

require 'rake'

require 'ore/tasks'
Ore::Tasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :test => :spec
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new  
task :doc => :yard

require 'yardstick/rake/measurement'
Yardstick::Rake::Measurement.new(:yardstick_measure) do |measurement|
  measurement.output = 'measurement/report.txt'
end

require 'yardstick/rake/verify'
Yardstick::Rake::Verify.new do |verify|
  verify.threshold = 80
end

desc "Run specs with rcov"
RSpec::Core::RakeTask.new("spec:rcov") do |t|
  t.rcov = true
  t.rcov_opts = %w{--exclude "spec\/,jsignal_internal"}
end

# for rcov threshold testing
rcov_coverage_threshold = 90
require_exact_rcov_threshold = false

desc "Verify that rcov coverage is at least #{rcov_coverage_threshold}%"
task :verify_rcov => "spec:rcov" do
  total_coverage = 0
  File.open("coverage/index.html").each_line do |line|
    if line =~ /<tt class='coverage_total'>\s*(\d+\.\d+)%\s*<\/tt>/
      total_coverage = $1.to_f
      break
    end
  end
  puts "Coverage: #{total_coverage}% (threshold: #{rcov_coverage_threshold}%)"
  raise "Coverage must be at least #{rcov_coverage_threshold}% but was #{total_coverage}%" if total_coverage < rcov_coverage_threshold
  raise "Coverage has increased above the threshold of #{rcov_coverage_threshold}% to #{total_coverage}%. You should update your threshold value." if (total_coverage > threshold) and require_exact_rcov_threshold
end