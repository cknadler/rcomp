require 'thor'

module RComp
  class CLI < Thor

    include Thor::Actions
    include RComp::Runner
    include RComp::Suite
    include RComp::Initializer

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
      guard_initialized

      unless command_exists?
        @conf.set_command(ask("Enter the command you want to test:"))
      end

      initialize_directories
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
      guard_uninitialized
      if @options[:grep]
        run_suite(load_suite(@options[:grep]), :test)
      else
        run_suite(load_suite, :test)
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
      guard_uninitialized

      # Display confirmation dialouge when -O is passed without filter
      if !@options[:grep] && options.overwrite
        unless yes? "This will overwrite all existing expected results."
          say 'Aborting...'
          exit 1
        end
      end

      if @options[:grep]
        run_suite(load_suite(@options[:grep]), :generate, @options)
      else
        run_suite(load_suite, :generate, @options)
      end
    end

    map "g" => :generate
  end
end
