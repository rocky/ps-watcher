require_relative './spec_helper'
describe "PSWatcher Config file load" do
  it 'should be able to load a YAML file' do
    DIR = File.dirname(__FILE__)
    config_file = File.join(DIR, %w(fixtures sample1.yml))
    psw = PSWatcher.new(:config_file => config_file)
    !!psw.should == true
  end
end
