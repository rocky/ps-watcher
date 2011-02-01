# This is an RSpec test. Run it via rspec (or rake)
require_relative './spec_helper'
describe "PSWatcher configuration file load" do
  before(:all) do
    DIR = File.dirname(__FILE__)
  end
  before(:each) do
    @logger = double('logger')
    @psw = PSWatcher.new(:logfile => @logger)
  end
  it 'should be able to load a YAML file' do
    config_file = File.join(DIR, %w(fixtures sample1.yml))
    @psw.read_config_file(config_file)
    !!@psw.should == true
    process_sections = @psw.instance_variable_get('@process_sections')
    process_sections.size.should == 5
  end
  it 'should should report an error on a bad YAML file' do
    @logger.should_receive(:puts).with(/error[:] Problem reading YAML configuration file/)
    @psw.read_config_file(__FILE__)
    !!@psw.should == true
  end
  it 'should should report an error on a nonexistent file' do
    @logger.should_receive(:puts)
    @psw.read_config_file(__FILE__ + 'xxx')
  end
end
