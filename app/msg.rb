# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
class PSWatcher
  # log error to syslog and print to stderr.
  def logger(msg)
    @opts[:logfile].puts msg if @opts[:logfile]
  end
    
  def err(msg)
    logger "** error: #{msg}"  
  end

  def debug_log(msg, level)
    logger "** debug: #{msg}" if @opts[:debug_level] > level 
  end
end
