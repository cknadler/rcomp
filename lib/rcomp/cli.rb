require 'thor'

module RComp
  class CLI < Thor

    include RComp::Actions
    include RComp::Runner
    include RComp::Suite

    def initialize(args=[], options={}, config={})
      super
      # load Conf singleton
      @conf = Conf.instance
    end

    ##
    ## CLI Commands
    ##
    
    # init
    desc "init", "Setup rcomp test directory"
    def init
      if initialized?
        puts "RComp already initialized"
        exit 1
      end

      unless Dir.exists?(File.dirname(@conf.root))
        puts "No directory #{File.dirname(@conf.root)}"
        exit 1
      end

      # Create RComp directories
      mkdir @conf.root
      mkdir @conf.test_root
      mkdir @conf.expected_root
      mkdir @conf.result_root

      puts "RComp successfully initialized"
    end

    # version
    desc "version", "Prints RComp's version information"
    def version
      puts "RComp version #{RComp::VERSION}"
    end
    map %w(-v --version) => :version

    # set-command
    desc "set_command COMMAND", "Sets the command RComp will run tests with"
    def set_command(command)
      @conf.set_conf_value("command", command)
    end
    map "c" => :set_command

    # set-directory
    desc "set_directory PATH", "Set the directory RComp will store files"
    def set_directory(path)
      @conf.set_conf_value("directory", path)
    end
    map "d" => :set_directory

    # test
    desc "test", "Run all tests"
    method_option :grep,
      :type => :string,
      :desc => "Only test files that match pattern"
    def test
      @conf.require_basic_conf
      if @options[:grep]
        run_suite(load_suite(@options[:grep]), :test)
      else
        run_suite(load_suite, :test)
      end
    end
    map "t" => :test

    # generate
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
      @conf.require_basic_conf

      # Display confirmation dialouge when -O is passed without filter
      if !@options[:grep] && options.overwrite
        confirm_action "This will overwrite all existing expected results."
      end

      if @options[:grep]
        run_suite(load_suite(@options[:grep]), :generate, @options)
      else
        run_suite(load_suite, :generate, @options)
      end
    end
    map "g" => :generate

    private

    def confirm_action(warning)
      puts warning
      print 'Are you sure? (Y/N) '
      confirm = STDIN.gets.chomp

      unless confirm.downcase == 'y'
        say 'Aborting...'
        exit 1
      end
    end

    def initialized?
      File.exists?(@conf.root) && 
      File.exists?(@conf.test_root) && 
      File.exists?(@conf.result_root) && 
      File.exists?(@conf.expected_root)
    end
  end
end
