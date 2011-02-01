# This is an RSpec test. Run it via rspec (or rake)
require_relative './spec_helper'
describe "PSWatcher singleton method tests" do
  it 'should be able to load a return a time string' do
    PSWatcher.timestring.should =~ /\d{2}(:?\/\d{2}){2} \d{2}:\d{2}.\d{2} .+[\d+]/
  end

  it 'should be able to show a version string and exit' do
    class PSWatcher
      def self.exit(exit_code)
        @@double.exit exit_code
      end
      def self.print(msg)
        @@double.print msg
      end
    end
    my_exit = double('exit')
    my_exit.should_receive(:exit).with(10)
    my_print = double('print')
    my_exit.should_receive(:print).
      with(/#{PSWatcher::PROGRAM} version #{PSWatcher::VERSION}/)
    PSWatcher.class_variable_set('@@double', my_exit)
    PSWatcher.version
  end
end

