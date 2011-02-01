#!/usr/bin/env ruby
require_relative './helper'
class TestGatherPsInfo < Test::Unit::TestCase
  include UnitHelper

  def setup
    PSWatcher.setup_options
    @psw = PSWatcher.new
  end

  def test_gather_ps_info
    # See if I can find my own pid
    list = @psw.gather_psinfo
    pids = list.select { |pid, cmd| pid == $$}
    assert_equal 1, pids.size
    assert(pids[0][1] =~ /#{$0}(:?\s+|$)/, 
           "#{pids[0][1]} should match #{$0}")
  end

  def test_get_full_ps_info
    # See if I can find my own pid
    output = @psw.get_full_ps_info($$)
    assert output
  end
end
