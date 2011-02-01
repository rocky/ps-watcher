#!/usr/bin/env ruby
require_relative './helper'
require 'tmpdir'
require 'fileutils'

# Check to see if we pick up configuration file changes
class TestCheckConfigFile < Test::Unit::TestCase
  include UnitHelper

  def test_basic
    config_name = 'simple1.yml'
    config_file = File.join(Dir::tmpdir, config_name)
    if File.exist?(config_file)
      unlinked = File.unlink config_file
      unless unlinked == 1
        puts "skipping #{__FILE} because file #{config_file} exists and we can't remove it"
        return
      end
    end
    orig_config_file = File.join(FIXTURE_DIR, config_name)
    FileUtils.cp orig_config_file, config_file
    begin
      @psw = PSWatcher.new(:config_file => config_file, :debug_level => -1)
      assert @psw.instance_variable_get('@stat')
      stat = @psw.check_config_file
      assert_equal nil, stat, "Check should not have caused a reread"
      # Now change the configuration file. 
      orig_config_file = File.join(FIXTURE_DIR, 'sample1.yml')
      FileUtils.cp orig_config_file, config_file
      stat = @psw.check_config_file
      assert_equal(true, !!stat, "Reread should occur")
    ensure
      File.unlink config_file
    end
  end
end

