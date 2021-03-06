#!/usr/bin/env ruby
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'yaml'
require_relative 'app/options'
require_relative 'app/msg'

class PSWatcher
  # Information for each section of a ps-watcher configuration file.
  PS_Struct = Struct.new(:re, :action, :trigger, :occurs)

  def initialize(opts={})
    @opts = DEFAULT_OPTS.merge(opts)
    @process_sections = []
    @ps_prog = @opts[:ps_prog] || 'ps'
    @ps_cmd = "#{@ps_prog} #{@opts[:ps_pid_opts]}"
    @ps_fullcmd_fmt = 
      if @opts[:opts_fullcmd_fmt] 
        @opts[:opts_fullcmd_fmt] 
      elsif @opts[:ps_vars] 
        "#{@ps_prog} -p %d -o #{@opts[:ps_vars].gsub(/\s+/,',')}"
      else
        "#{@ps_prog} -lp %d"
      end
      
    read_config_file if @opts[:config_file]
  end

  def finalize
    @syslog.close if @syslog
  end

  # Evaluates the trigger and if that's true also performs
  # an action. true is returned if the action was performed, 
  # false otherwise.
  # FIXME: should set up a closure or block and eval in that context.
  def eval_trigger_action(trigger, action)
    debug_log("trigger: #{trigger.inspect}", 2);
    if !trigger || eval(trigger)
      debug_log("running action: #{action}", 2);
      eval action 
      true
    else
      false
    end
  end

  # Run a system ps command to get a list of processes and process ids.
  # Return an Array of tuples where each tuple is [pid, command-name]
  def gather_psinfo
    `#{@ps_cmd}`.split(/\n/).map do |line|
      if line =~ /\s*(\d+) (.+)$/
        [$1.to_i, $2]
      else
        nil
      end
    end.compact
  end

  # Get up full information for process pid.
  def get_full_ps_info(pid)
    ps_fullcmd = @ps_fullcmd_fmt % pid
    # p ps_fullcmd
    output = `#{ps_fullcmd}`
    return output
  end
    
  def make_the_rounds
    debug_log('Making the rounds', 1)
    # require 'trepanning'; debugger
    ps_info=gather_psinfo()
    @process_sections.each do |section|
      debug_log("process pattern: #{section.re}", 1);
      in_prolog_epilog = false
      @count = 0
      ps_pat = section.re
      if ps_pat == /^\$PROLOG/ || ps_pat == /\$EPILOG/ 
        # Set to run trigger below.
        @count = 1
        in_prolog_epilog = true
      else
        selected_ps = ps_info.select do |psi|
          psi[1] =~ ps_pat
        end
        @count = selected_ps.size
        debug_log("@count for #{ps_pat}: #{@count}", 2);
      end
      if in_prolog_epilog
        # execute trigger
        eval_trigger_action(section.trigger, section.action)
      elsif :none == section.occurs
        if 0 == @count 
	  # execute the trigger anyway
	  eval_trigger_action(section.trigger, section.action)
        end
      elsif @count > 0
        selected_ps.each do |pid, command|
          next unless get_full_ps_info(pid)
	  eval_trigger_action(section.trigger, section.action)
          break if :first == section.occurs
        end
      end
    end
  end

  def read_config_file(config_file=@opts[:config_file])
    unless File.readable?(config_file)
      err("Can't read #{config_file}")
      return nil
    end
    @yaml = YAML.load_file(config_file)
    unless @yaml && @yaml.kind_of?(Hash)
      err("Problem reading YAML configuration file #{config_file}") 
      return nil
    end
    unless @yaml.member?('process_patterns')
      err("'process_patterns' section not in YAML configuration file #{config_file}") 
      return nil
    end
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

  # Returns new stat if configuration file changed. Otherwise returns nil
  def check_config_file
    stat = stat_config_file
    logger("checking config file #{@config_file}") if @opts[:debug_level] > 1
    if stat && (stat.size != @stat.size || @stat.mtime < stat.mtime )
      logger("Configuration file #{@config_file} modified; re-reading...") if 
        @opts[:debug_level] >= 0
      read_config_file
      return stat
    end
    return nil
  end

  def run
    while true
      make_the_rounds
      sleep @opts[sleep_interval] if @opts[:sleep_interval] > 0
      check_config_file
      break if @opts[:sleep_interval] < 0
    end
  end

  def self.main(config_file)
    setup_options = {}
    opts = PSWatcher.setup_options(setup_options)
    setup_options[:config_file] = config_file
    psw = PSWatcher.new(setup_options)
  end

end

require 'optparse'

if __FILE__ == $0
  DIR = File.dirname(__FILE__)
  config_file = File.join(DIR, %w(test fixtures simple1.yml))
  psw = PSWatcher.main(config_file)
  psw.run
end
