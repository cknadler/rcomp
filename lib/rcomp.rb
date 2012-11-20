###
# = Overview
#
# RComp is a simple test framework for testing command line applications 
# output. It works by passing a specified command "tests", in the form 
# of files, as arguments. It was designed for testing programming
# languages.

# external
require 'thor'

class RComp < Thor

  # internal
  require 'rcomp/conf'
  require 'rcomp/actions'
  require 'rcomp/suite'
  require 'rcomp/runner'
  require 'rcomp/path'

  include RComp::Actions
  include RComp::Suite
  include RComp::Runner
  include RComp::Path

  map "c" => :set_command
  map "d" => :set_directory
  map "g" => :generate
  map "t" => :test

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

  # set-command
  desc "set_command COMMAND", "Sets the command RComp will run tests with"

  def set_command(command)
    @conf.set_conf_value("command", command)
  end

  # set-directory
  desc "set_directory PATH", "Set the directory RComp will store files"

  def set_directory(path)
    @conf.set_conf_value("directory", path)
  end

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
