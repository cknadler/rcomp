# stdlib
require 'singleton'
require 'yaml'

# internal
require 'rcomp/actions'

class RComp
  class Conf

    include Singleton
    include RComp::Actions

    attr_reader :root, :test_root, :result_root, :expected_root, 
                :command

    # Initialize a new config object
    #
    # Loads options from config file, merges with defaults
    # and stores everything in memory
    def initialize
      # Config file path
      @path = '.rcomp'
    
      # Set valid keys for config file
      @valid_keys = ['directory',
                     'command']

      # Set default options and overwrite with config file options
      @default = { 'directory' => 'rcomp' }
      @custom = read_conf_file
      @conf = @default.merge(@custom)

      # Load configuration values into attributes
      @command = @conf['command']
      @root = @conf['directory']
      @test_root = @root + '/tests'
      @result_root = @root + '/results'
      @expected_root = @root + '/expected'
    end

    # Set a configuration value and write it to the config file
    #
    # Returns nothing
    def set_conf_value(key, value)
      @custom[key] = value
      puts "#{key} set to #{value}"
      write_conf_file
    end
    
    # Emit error unless all required conf keys are present in conf file
    #
    # Returns nothing
    def require_basic_conf
      require_command
      require_root_exists
      require_root_subdirs
    end


    private

    # Write the current config options to the config file
    #
    # Returns nothing
    def write_conf_file
      exit 1 unless @path
      touch @path unless File.exists?(@path)
      conf_file = File.open(@path, 'w')
      conf_file.puts YAML.dump @custom
    end
    
    # Read the config options from RComp's configuration file
    #
    # Returns a Hash of config options
    def read_conf_file
      conf = {}

      if File.exists?(@path) && File.size?(@path)

        # Store valid conf keys
        YAML.load_file(@path).each do |key, value|

          if @valid_keys.include? key
            conf[key] = value
          else
            say "Invalid configuration key: #{key}"
          end
        end
      end

      conf
    end

    # Require the command config option to be set
    # Print error and exit otherwise
    #
    # Returns nothing
    def require_command
      unless @command
        puts "No command present"
        puts "Run rcomp -e PATH to add a command to test with"
        exit 1
      end
    end

    # Require the existance of the root directory
    # Print error and exit otherwise
    #
    # Returns nothing
    def require_root_exists
      unless File.exists? @root
        puts "No RComp directory. Run rcomp init to create"
        exit 1
      end
    end

    # Require all sudirectories of the root directory to exist
    # Print error and exit otherwise
    #
    # Returns nothing
    def require_root_subdirs
      unless File.exists?(@test_root) && 
        File.exists?(@result_root) && 
        File.exists?(@expected_root)
        puts "Missing RComp directories at #{@root}"
        puts "Run rcomp init to repair"
        exit 1
      end
    end
  end
end
