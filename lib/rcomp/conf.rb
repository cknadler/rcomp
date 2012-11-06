class RComp
  module Conf

    # Conf file IO
    
    def load_conf

      @conf = {}
      
      if File.exists?(conf_path) && File.size?(conf_path)
        # Store valid conf keys
        YAML.load_file(conf_path).each do |conf_key, conf_value|
          if conf_keys.include? conf_key
            @conf[conf_key] = conf_value
          else
            say "Invalid configuration key: #{conf_key}", :yellow
          end
        end
      end
    end

    def write_conf
      touch conf_path unless File.exists?(conf_path)
      conf_file = File.open(conf_path, 'w')
      conf_file.puts YAML.dump @conf
    end

    def initialized?
      root_path && 
        File.exists?(root_path) && 
        File.exists?(test_root_path) && 
        File.exists?(result_root_path) && 
        File.exists?(expected_root_path)
    end

    # Conf file error checking
    
    # Emit error unless all required conf keys are present in conf file
    def require_basic_conf
      require_executable_path
      require_executable_exists
      require_root_path
      require_root_exists
      require_root_subdirs
    end
    
    def require_executable_path
      unless executable_path
        say "No executable path present. RComp needs the path to an executable to test.", :red
        say "Run rcomp -e PATH to add your executable path.", :red
        exit 1
      end
    end

    def require_executable_exists
      unless File.exists? executable_path
        say "Executable doesn't exist at path #{executable_path}.", :red
        say "Run rcomp -e PATH to change your executable path.", :red
        exit 1
      end
    end

    def require_root_path
      unless root_path
        say "No test directory path present.", :red
        say "Run rcomp -d PATH to specify where rcomp should store tests.", :red
        exit 1
      end
    end

    def require_root_exists
      unless File.exists? root_path
        say "Tests file doesn't exist at path #{root_path}.", :red
        say "Run rcomp init to create the directory at #{root_path}.", :red
        exit 1
      end
    end

    def require_root_subdirs
      unless File.exists?(test_root_path) && File.exists?(result_root_path) && File.exists?(expected_root_path)
        say "Test subdirectories not initilized inside #{root_path}.", :red
        say "Run rcomp init to create the required subdirectories in #{root_path}.", :red
        exit 1
      end
    end

    private

    def conf_keys
      ["tests_directory", 
       "executable"]
    end
  end
end
