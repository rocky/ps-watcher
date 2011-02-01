# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
class PSWatcher
  # log error to syslog and print to stderr.
  def logger(msg)
    if @opts[:syslog] 
      # Well, perhaps more later...
    end
    if @opts[:logfile]
      @opts[:logfile].puts msg
    end
  end
    
  def err(msg)
    logger "** error: #{msg}"  
  end

  def debug_log(msg, level)
    logger "** debug: #{msg}" if @opts[:debug_level] > level 
  end
end
