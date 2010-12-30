require 'yaml'
class PSWatcher
  DEFAULT_OPTS = {
    :sleep_interval => -1,
    :debug_level => 3,
    # FIXME: get from OS configuration
    :ps_prog => '/bin/ps',
    :ps_pid_opts => '-e -o pid= -o cmd='
  }

  PS_Struct = Struct.new(:re, :trigger, :action, :occurs)
  def initialize(opts={})
    @opts = DEFAULT_OPTS.merge(opts)
    @process_sections = []
    @ps_cmd = "#{@opts[:ps_prog]} #{@opts[:ps_pid_opts]}"; 
    read_config_file if @opts[:config_file]
  end

  def logger(msg)
    puts msg
  end
    
  def err(msg)
    logger "** errors #{msg}"  
  end

  def debug_log(msg, level)
    logger "** debug #{msg}" if @opts[:debug_level] > level 
  end

  def gather_psinfo
    `#{@ps_cmd}`.split(/\n/).map do |line|
      if line =~ /\s*(\d+) (.+)$/
        [$1.to_i, $2]
      else
        nil
      end
    end.compact
  end
    
  def make_the_rounds
    debug_log('Making the rounds', 1)
    require 'trepanning'; debugger
    ps_info=gather_psinfo()
    @process_sections.each do |section|
      debug_log("process pattern: #{section.re}", 1);
      in_prolog_epilog = false
      count = 0
      ps_pat = section.re
      if ps_pat == /^\$PROLOG/ || ps_pat == /\$EPILOG/ 
        # Set to run trigger below.
        count  = @ps_info
        in_prolog_epilog = true
      else
        selected_ps = ps_info.select do |psi|
          psi[1] =~ ps_pat
        end
        count = selected_ps.size
        debug_log("count for #{ps_pat}: #{count}", 2);
      end
    end
  end

  def read_config_file(config_file=@opts[:config_file])
    unless File.readable?(config_file)
      err("Can't read #{config_file}")
      return
    end
    @yaml = YAML.load_file(config_file)
    @yaml['process_patterns'].each do |name, y_section|
      regexp_str = y_section['regexp']
      begin
        regexp = eval(regexp_str)
      rescue
        err("process_pattern section #{name} failed eval of regexp #{regexp_str}")
        next
      end
      unless regexp.kind_of?(Regexp) 
        err("process_pattern section #{name} has invalid regexp #{regexp_str}")
        next
      end
      action = nil
      trigger = true
      %w(action trigger).each do |field|
        val = eval("y_section[\"#{field}\"]")
        eval("#{field}= #{val.inspect}")
      end
      occurs = y_section['occurs']
      occurs = 
        if occurs
          occurs.strip!
          unless %w(none first first-trigger every).member?(occurs)
            err("process_pattern section #{name} has invalid occurs #{occurs}")
            next
          end
          occurs.to_sym
        else
          :first
        end
      section = PS_Struct.new(regexp, action, trigger, occurs)
      @process_sections << section
    end
    @config_file = config_file
    @stat = stat_config_file
  end

  def stat_config_file
    return File::stat(@config_file)
  end
    
  def check_config_file
    stat = stat_config_file
    logger("checking config file #{@conf_file}") if @opts[:debug_level] > 1
    if stat.respond_to?(:mtime) && stat.mtime  && @stat.mtime < stat.mtime  
      logger("Configuration file #{@conf_file} modified; re-reading...");
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
  config_file = File.join(DIR, %w(spec fixtures sample1.yml))
  psw = PSWatcher.new(:config_file => config_file)
  psw.run
end
