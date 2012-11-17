###
# = Overview
#
# RComp is a simple test framework for testing command line applications 
# that require an input file. The tool was designed for testing programming
# languages.

# external
require 'thor'

class RComp < Thor

  # internal
  require 'rcomp/conf'
  require 'rcomp/actions'

  include RComp::Actions

  map "c" => :set_command
  map "d" => :set_directory
  map "g" => :generate
  map "ga" => :generate_all
  map "t" => :test
  map "ta" => :test_all

  def initialize(args=[], options={}, config={})
    super
    # load Conf singleton
    @conf = Conf.instance
  end

  ##
  ## CLI Commands
  ##
  
  # init
  desc "init", "Setup rcomp test directory based on current configuration"

  def init
    if initialized?
      say "RComp already initialized"
      exit 1
    end

    unless Dir.exists?(File.dirname @conf.root)
      say "No directory #{File.dirname @conf.root}"
      exit 1
    end

    # Create RComp directories
    mkdir @conf.root
    mkdir @conf.test_root
    mkdir @conf.expected_root
    mkdir @conf.result_root

    say "RComp successfully initialized"
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
  desc "test PATH", "Run specified test or test directory of tests"

  def test(path)
    require_basic_conf
    suite = Suite.new(path)
    runner = Runner.new(suite)
    runner.run(:test)
  end

  # test-all
  desc "test-all", "Run all tests"

  def test_all
    require_basic_conf
    suite = Suite.new
    runner = Runner.new(suite)
    runner.run(:test)
  end

  # generate
  desc "generate PATH", "Generate expected output for test(s)"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :aliases => "-O",
    :desc => "Overwrite expected output file for test if present"

  def generate(path)
    require_basic_conf
    suite = Suite.new(path)
    runner = Runner.new(suite)
    runner.run(:generate, @options)
  end

  # generate-all
  desc "generate-all", "Generate expected output for all tests without it"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :aliases => "-O",
    :desc => "Overwrite expected output file for all tests if present"

  def generate_all
    require_basic_conf

    if @options[:overwrite]
      confirm_action "This will overwrite all existing expected results."
    end

    suite = Suite.new
    runner = Runner.new(suite)
    runner.run(:generate, @options)
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
