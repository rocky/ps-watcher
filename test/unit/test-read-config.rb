require_relative './helper'
class TestReadConfig < Test::Unit::TestCase
  include UnitHelper

  def setup
    @psw = PSWatcher.new
    $errors = []
    $debug_log = []
    $msgs = []
    def @psw.err(msg)
      $errors << msg
    end
    def @psw.logger(msg)
      $msgs << msg
    end
    def @psw.debug_log(msg)
      $debug_log << msg
    end
  end

  def test_basic
    config_file = File.join(FIXTURE_DIR, 'sample1.yml')
    @psw.read_config_file(config_file)
    assert_equal true, $errors.empty?, @errors
    process_sections = @psw.instance_variable_get('@process_sections')
    assert_equal 5, process_sections.size
  end
  def test_bad_config_file
    @psw.read_config_file(__FILE__)
    assert_equal false, $errors.empty?, @errors
    $errors = []
    
    @psw.read_config_file(__FILE__ +'xy')
    assert_equal false, $errors.empty?, @errors
  end
end

