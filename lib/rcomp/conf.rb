require 'singleton'
require 'yaml'

module RComp
  class Conf

    include Singleton
    include RComp::Actions

    attr_reader :root, :test_root, :result_root, :expected_root, 
                :command, :ignore, :timeout

    # Conf file path
    CONF_PATH = '.rcomp'

    # Valid configuraiton keys
    VALID_KEYS = ['directory',
                  'command',
                  'ignore',
                  'timeout']

    # Default configuration options
    DEFAULT = { 'directory' => 'rcomp',
                'timeout'   => 5 }

    # Initialize a new config object
    #
    # Loads options from config file, merges with defaults
    # and stores everything in memory
    def initialize
      # Load custom configuration and merge it with defaults
      @custom = read_conf_file
      @conf = DEFAULT.merge(@custom)

      # Load configuration values into attributes
      @command = @conf['command']
      @ignore = @conf['ignore']
      @ignore ||= []
      @timeout = @conf['timeout']
      @root = @conf['directory']
      @test_root = @root + '/tests'
      @result_root = @root + '/results'
      @expected_root = @root + '/expected'
    end

    # Set a command as a custom configuration value
    #
    # Returns nothing
    def set_command(command)
      @custom['command'] = command
      puts "Command set to #{command}"
      write_conf_file
    end
   
    private

    # Write the current custom config options to the config file
    #
    # Returns nothing
    def write_conf_file
      touch CONF_PATH unless File.exists?(CONF_PATH)
      conf_file = File.open(CONF_PATH, 'w')
      conf_file.puts YAML.dump @custom
    end
    
    # Read the config options from RComp's configuration file
    #
    # Returns a Hash of config options
    def read_conf_file
      conf = {}
      if File.exists?(CONF_PATH) && File.size?(CONF_PATH)
        # Store valid conf keys
        YAML.load_file(CONF_PATH).each do |key, value|
          if VALID_KEYS.include? key
            conf[key] = value
          else
            say "Invalid configuration key: #{key}"
          end
        end
      end
      conf
    end
  end
end
