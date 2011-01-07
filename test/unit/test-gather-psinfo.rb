#!/usr/bin/env ruby
require_relative './helper'
class TestGatherPsInfo < Test::Unit::TestCase
  include UnitHelper

  def setup
    @psw = PSWatcher.new
  end

  def test_basic
    # See if I can find my own pid
    list = @psw.gather_psinfo
    pids = list.select { |pid, cmd| pid == $$}
    assert_equal 1, pids.size
    assert(pids[0][1] =~ /#{$0}(:?\s+|$)/, 
           "#{pids[0][1]} should match #{$0}")
  end
end

