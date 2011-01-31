#!/usr/bin/env ruby
# Class singleton functions other than option processing.
# Copyright (C) 2010, 2011 Rocky Bernstein <rockyb@rubyforge.net>
require 'rbconfig'
class PSWatcher
  VERSION = '2.0'
  PROGRAM = 'ps-watcher'
  def self.version
    print <<-BANNER
ps-watcher version #{VERSION} Copyright (C) 2011 Rocky Bernstein.
This is free software; see the source for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
    BANNER
    exit 10
  end

  # Return time and PID as string in a common format
  def self.timestring
    Time.now.strftime("%m/%d/%y %H:%M.%S #{PROGRAM}[#{$$}]")
  end
end

if __FILE__ == $0
  puts PSWatcher.timestring
  PSWatcher.version
end
