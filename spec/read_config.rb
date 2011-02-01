require_relative './spec_helper'
describe "PSWatcher Config file load" do
  before(:all) do
    DIR = File.dirname(__FILE__)
  end
  before(:each) do
    @psw = PSWatcher.new
    $errors = []
    $msgs = []
    $debug_log = []
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
  it 'should be able to load a YAML file' do
    config_file = File.join(DIR, %w(fixtures sample1.yml))
    @psw.read_config_file(config_file)
    !!@psw.should == true
    $errors.should be_empty
    process_sections = @psw.instance_variable_get('@process_sections')
    process_sections.size.should == 5
  end
  it 'should should report an error on a bad YAML file' do
    @psw.read_config_file(__FILE__)
    !!@psw.should == true
    $errors.should_not be_empty
  end
  it 'should should report an error on a nonexistent file' do
    @psw.read_config_file(__FILE__ + 'xxx')
    $errors.should_not be_empty
  end
end
