require 'thor'

module RComp
  class CLI < Thor

    include Thor::Actions

    def initialize(args=[], options={}, config={})
      super
      # load Conf singleton
      @conf = Conf.instance
    end

    ###
    # CLI Commands
    ###
    
    desc "init", "Setup rcomp test directory"
    def init
      Initializer.guard_initialized

      unless Initializer.command_exists?
        @conf.set_command(ask("Enter the command you want to test:"))
      end

      Initializer.initialize_directories
      puts "RComp successfully initialized"
    end


    desc "version", "Prints RComp's version information"
    def version
      puts "RComp version #{RComp::VERSION}"
    end

    map %w(-v --version) => :version


    desc "test", "Run all tests"
    method_option :grep,
      :type => :string,
      :desc => "Only test files that match pattern"
    def test
      Initializer.guard_uninitialized
      if @options[:grep]
        Runner.run(Suite.load(@options[:grep]), :test)
      else
        Runner.run(Suite.load, :test)
      end
    end

    map "t" => :test


    desc "generate", "Generate expected output for all tests"
    method_option :grep,
      :type => :string,
      :desc => "Only test files that match pattern"
    method_option :overwrite, 
      :type => :boolean,
      :default => false,
      :aliases => "-O",
      :desc => "Overwrite expected output file for test if present"
    def generate
      Initializer.guard_uninitialized

      # Display confirmation dialouge when -O is passed without filter
      if !@options[:grep] && options.overwrite
        unless yes? "This will overwrite all existing expected results."
          say 'Aborting...'
          exit 1
        end
      end

      if @options[:grep]
        Runner.run(Suite.load(@options[:grep]), :generate, @options)
      else
        Runner.run(Suite.load, :generate, @options)
      end
    end

    map "g" => :generate
  end
end
