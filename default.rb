require 'rbconfig'
require 'yaml'
class PSWatcher

  DEFAULT_OPTS = {
    :sleep_interval => -1,
    :debug_level => 3,
    :logfile => $stdout,
    # FIXME: get from OS configuration
    # :ps_prog => '/bin/ps',
    # :ps_pid_opts => '-w -w -e -o pid= -o cmd='
  }

  def self.set_default_options(default_opts=DEFAULT_OPTS)
    base_dir = File.dirname(__FILE__)
    default_os_yaml = YAML.load_file(File.join(base_dir, 'os.yml'))
    target_os = RbConfig::CONFIG['target_os']
    if ps_info_defaults = default_os_yaml[target_os]
      %w(ps_prog ps_pid_opts).each do |field|
        default_opts[field.to_sym] = ps_info_defaults[field]
      end
      default_opts
    else
      nil
    end
  end
end

if __FILE__ == $0
  x = PSWatcher.set_default_options
  # require 'rubygems'; require 'trepanning'; 
  # debugger
  require 'pp'
  PP.pp(x)
end
