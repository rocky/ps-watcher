# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
# Options processing part of ps-watcher
require 'optparse'
require_relative 'single'
require_relative 'default'
class PSWatcher
  def self.setup_options(options=DEFAULT_OPTS, stdout=$stdout, stderr=$stderr)
    default_opts = set_default_options(options)
    OptionParser.new do |opts|
      opts.on('--version', "show a version string and exit") do 
        version
      end
      opts.on('--[no]syslog',
              "send ordon't seend error output to syslog") do |v|
        options[:syslog] = v
      end
      opts.on('--version', "show a version string and exit") do 
        version
      end
      opts.on('--debug LEVEL', Integer,
              ("give debugging output. " + 
              "The higher the number, the more the output")
              ) do |level|
        options[:debug_level] = level
      end
      opts.on('--pid-dir DIRECTORY', String,
              ("directory to store process id of running program. " + 
              "The default is #{default_opts[:pid_dir]}")
              ) do |pid_dir|
        if File.directory?(pid_dir)
          options[:pid_dir] = pid_dir
        else
          $stderr.puts("#{pid_dir} is not a directory; --pid-dir option ignored")
        end
      end
      opts.on("--sleep SECONDS", Integer, 
              "sleep interval between iterations. The default is " + 
              "#{default_opts[:sleep_interval]} seconds.") do |num|
        options[:sleep_interval] = num
      end
      opts.on('--ps-prog', 
              "command that gets ps information. The default is: " + 
              "#{options[:ps_prog]}",
              String) do |ps_prog|
        options[:ps_prog] = ps_prog
      end
    end
  end
end
if __FILE__ == $0
  require 'pp'
  require 'tmpdir'
  opts = nil
  [%w(--sleep 5), %w(--debug 0),
   %W(--pid-dir #{Dir.tmpdir})].each do |o|
    options = PSWatcher::DEFAULT_OPTS.dup
    opts    = PSWatcher.setup_options(options)
    rest    = opts.parse *o
    PP.pp(options)
    p rest
    puts '=' * 10
  end
  p opts
  [%W(--pid-dir #{__FILE__})].each do |o|
    options = PSWatcher::DEFAULT_OPTS.dup
    opts    = PSWatcher.setup_options(options)
    rest    = opts.parse *o
  end
end
