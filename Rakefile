#!/usr/bin/env rake
# -*- Ruby -*-
require 'fileutils'

ROOT_DIR = File.dirname(__FILE__)

desc 'Remove built files'
task :clean do
  Dir.chdir File.join(ROOT_DIR, 'ext') do
    if File.exist?('Makefile')
      sh 'make clean'
      rm 'Makefile'
    end
    derived_files = Dir.glob('.o') + Dir.glob('*.so')
    rm derived_files unless derived_files.empty?
  end
end

require 'rbconfig'
RUBY_PATH = File.join(RbConfig::CONFIG['bindir'],  
                      RbConfig::CONFIG['RUBY_INSTALL_NAME'])
def run_standalone_ruby_file(directory)
  puts ('*' * 10) + ' ' + directory + ' ' + ('*' * 10)
  Dir.chdir(directory) do
    Dir.glob('*.rb').each do |ruby_file|
      puts ('-' * 20) + ' ' + ruby_file + ' ' + ('-' * 20)
      system(RUBY_PATH, ruby_file)
    end
  end
end

desc "Create a GNU-style ChangeLog via git2cl"
task :ChangeLog do
  system("git log --pretty --numstat --summary | git2cl > ChangeLog")
end

task :default => [:test]

require 'rake/testtask'
desc 'Test units - the smaller tests'
Rake::TestTask.new(:'test:unit') do |t|
  t.test_files = FileList['test/unit/**/*.rb']
  # t.pattern = 'test/**/*test-*.rb' # instead of above
  t.verbose = true
end

desc 'Test everything - unit tests for now.'
task :test do
  exceptions = ['test:unit'].collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      e
    end
  end.compact
  
  exceptions.each {|e| puts e;puts e.backtrace }
  raise "Test failures" unless exceptions.empty?
end

desc "test in isolation."
task :'check' do
  run_standalone_ruby_file(File.join(%W(#{ROOT_DIR} test unit)))
end

# ---------  RDoc Documentation ------
require 'rake/rdoctask'
desc 'Generate rdoc documentation'
Rake::RDocTask.new('rdoc') do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'rb-threadframe'
  # Make the readme file the start page for the generated html
  rdoc.options += %w(--main  README.md)
  rdoc.rdoc_files.include('ext/**/*.c',
                          'README.md')
end
desc "Same as rdoc"
task :doc => :rdoc

task :clobber_package do
  FileUtils.rm_rf File.join(ROOT_DIR, 'pkg')
end

task :clobber_rdoc do
  FileUtils.rm_rf File.join(ROOT_DIR, 'doc')
end
