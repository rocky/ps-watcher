#!/usr/bin/env ruby
require 'test/unit'
require_relative '../../ps-watcher'
class TestSingleton < Test::Unit::TestCase
  def test_basic
    assert_match(/\d{2}(:?\/\d{2}){2} \d{2}:\d{2}.\d{2} .+[\d+]/,
                 PSWatcher.timestring)
  end
end
