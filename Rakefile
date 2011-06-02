# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "ruby-usb-pro"
  gem.homepage = "http://github.com/DavidEGrayson/ruby-usb-pro"
  gem.license = "MIT"
  gem.summary = %Q{Ruby library for controlling USB devices.}
  gem.description = <<END
This is a Ruby library for controlling USB devices.
On Linux platforms, it is implemented with libusb-1.0 and exposes all
the features of libusb-1.0.
However, I would not consider this library to be a simple binding or
wrapper for libusb because I am planning for it to build many things
on top of libusb.  Also, because this is Ruby, the interface will be
very different from libusb's interface. 
END
  gem.email = "davidegrayson@gmail.com"
  gem.authors = ["David Grayson"]
  gem.extensions = ["ext/extconf.rb"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ruby-usb-pro #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
