require_relative './helper'
class TestReadConfig < Test::Unit::TestCase
  include UnitHelper

  def setup
    @psw = PSWatcher.new
    @errors = []
    @debug_log = []
    @msgs = []
    # def @psw.err(msg)
    #   @errors << msg
    # end
    # def @psw.logger(msg)
    #   @msgs << msg
    # end
    # def @psw.debug_log(msg)
    #   @debug_log << msg
    # end
  end

  def test_basic
    config_file = File.join(FIXTURE_DIR, 'sample1.yml')
    @psw.read_config_file(config_file)
    assert_equal true, @errors.empty?, @errors
  end
end

