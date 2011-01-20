# Options processing part of ps-watcher
require 'optparse'
require_relative 'single'
class PSWatcher
  DEFAULT_OPTS = {
    :sleep_interval => -1,
    :debug_level => 3,
    :logfile => $stdout,
    # FIXME: get from OS configuration
    :ps_prog => '/bin/ps',
    :ps_pid_opts => '-w -w -e -o pid= -o cmd='
  }
  def self.setup_options(options, stdout=$stdout, stderr=$stderr)
    OptionParser.new do |opts|
      opts.on('--version', "show a version string and exit") do 
        version
      end
      opts.on('--debug LEVEL', Integer,
              ("give debugging output. " + 
              "The higher the number, the more the output")
              ) do |level|
        options[:debug_level] = level
      end
      opts.on("--sleep SECONDS", Integer, 
              "sleep interval between iterations. The default is " + 
              "#{DEFAULT_OPTS[:sleep_interval]} seconds.") do |num|
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
  [%w(--sleep 5), %w(--debug 0)].each do |o|
    options = PSWatcher::DEFAULT_OPTS.dup
    opts    = PSWatcher.setup_options(options)
    rest    = opts.parse *o
    p options
    puts '=' * 10
  end
end
