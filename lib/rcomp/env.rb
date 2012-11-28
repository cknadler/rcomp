module RComp
  module Env

    extend self
    extend Actions

    @@conf = Conf.instance

    # Emit error unless RComp is fully initialized
    #
    # Returns nothing
    def guard_uninitialized
      guard_command_exists
      guard_root_dir_exists
      guard_root_subdirs_exist
    end

    # Emit error unless RComp is not fully initialized
    #
    # Returns nothing
    def guard_initialized
      if initialized?
        puts "RComp already initialized"
        exit 1
      end
    end

    # Create RComp directories if they don't already exist
    # 
    # Returns nothing
    def initialize_directories
      mkpath @@conf.root
      mkdir @@conf.test_root
      mkdir @@conf.expected_root
      mkdir @@conf.result_root
    end
    
    # Checks for the existance of a command to test with
    #
    # Returns a boolean
    def command_exists?
      @@conf.command
    end

    private
    
    # Checks for the existance of RComp's root directory
    #
    # Returns a boolean
    def root_dir_exists?
      File.exists?(@@conf.root)
    end

    # Checks for the existance of the required subdirectories inside
    # of RComp's root directory
    #
    # Returns a boolean
    def root_subdirs_exist?
      File.exists?(@@conf.test_root) && 
      File.exists?(@@conf.result_root) && 
      File.exists?(@@conf.expected_root)
    end

    # Checks to see if RComp is fully initialized
    #
    # Returns a boolean
    def initialized?
      command_exists? &&
        root_dir_exists? &&
        root_subdirs_exist?
    end

    # Require the command config option to be set
    # Print error and exit otherwise
    #
    # Returns nothing
    def guard_command_exists
      unless command_exists?
        puts "No command present"
        puts "Run rcomp init to setup"
        exit 1
      end
    end

    # Require the existance of the root directory
    # Print error and exit otherwise
    #
    # Returns nothing
    def guard_root_dir_exists
      unless root_dir_exists?
        puts "No RComp directory"
        puts "Run rcomp init to create"
        exit 1
      end
    end

    # Require all sudirectories of the root directory to exist
    # Print error and exit otherwise
    #
    # Returns nothing
    def guard_root_subdirs_exist
      unless root_subdirs_exist?
        puts "Missing RComp directories at #{@@conf.root}"
        puts "Run rcomp init to repair"
        exit 1
      end
    end
  end
end
