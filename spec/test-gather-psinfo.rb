# This is an RSpec test. Run it via rspec (or rake)
require_relative './spec_helper'
describe 'PSWatcher gather_psinfo' do

  before(:all) do 
    PSWatcher.setup_options
  end
  before(:each) do
    @psw = PSWatcher.new
  end

  it 'should be able to find my own pid' do
    list = @psw.gather_psinfo
    pids = list.select { |pid, cmd| pid == $$}
    pids.size.should == 1
    pids[0][1].should =~ /#{$0}(:?\s+|$)/
  end
end

