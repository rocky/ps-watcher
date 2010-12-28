require 'yaml'
class PSWatcher
  DEFAULT_OPTS = {
    :sleep_interval => -1
  }
  def initialize(config_file, opts={})
    @opts = DEFAULT_OPTS.merge(opts)
    @config_file = config_file
    read_config_file
  end

  def check_config_file
    puts "Checking config"
  end

  def logger(msg)
    puts msg
  end
    
  def err(msg)
    puts "** msg"
  end
    
  def make_the_rounds
    puts "Making the rounds"
  end

  def read_config_file
    unless File.readable?(@config_file)
      err("Can't read #{@config_file}")
      return
    end
    tree = YAML.load_file(@config_file)
    @stat = stat_config_file
  end

  def stat_config_file
    return File::stat(@config_file)
  end
    
  def check_config_file
    new_stat = stat_config_file
    if false # defined($conf_time) && defined($mtime) && $conf_time < $mtime  
      logger("Configuration file $conf_file modified; re-reading...");
      read_config_file
    end
  end

  def run
    while true
      make_the_rounds
      sleep @opts[sleep_interval] if @opts[:sleep_interval] > 0
      check_config_file
      break if @opts[:sleep_interval] < 0
    end
  end
end

require 'optparse'

if __FILE__ == $0
  DIR = File.dirname(__FILE__)
  psw = PSWatcher.new(File.join(DIR, %w(test fixtures sample1.yml)))
  psw.run
end
