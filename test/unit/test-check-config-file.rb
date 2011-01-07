#!/usr/bin/env ruby
require_relative './helper'
require 'tmpdir'
class TestCheckConfigFile < Test::Unit::TestCase
  include UnitHelper

  def setup
    @psw = PSWatcher.new
  end

  def test_basic
    # See if we pick up modifications to a config file.
    # FIXME: to be continued...
    assert true
  end
end

