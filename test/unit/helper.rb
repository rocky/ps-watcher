require_relative '../../ps-watcher'
require 'test/unit'
module UnitHelper
  unless defined?(TEST_UNIT_DIR)
    TEST_UNIT_DIR = File.dirname(__FILE__)
    FIXTURE_DIR = File.join(TEST_UNIT_DIR, '..', 'fixtures')
  end
  def common_setup
  end
end
