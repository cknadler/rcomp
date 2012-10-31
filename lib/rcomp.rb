require 'thor'
require 'yaml'

###
# = Overview
#
# RComp is a simple test framework for testing command line applications 
# that require an input file. The tool was designed for testing programming
# languages but has a wide array of uses.

class RComp < Thor
  map "-e" => :set_executable
  map "-d" => :set_tests_directory

  autoload :Actions, 'rcomp/actions'

  include RComp::Actions

  def initialize(args=[], options={}, config={})
    super
    
    if File.exists? config_path
      config_file = YAML.load_file config_path

      if config_file
        config_file.each do |key, value|
          @config[key] = value if config_keys.include?(key)
        end
      end
    end
  end

  # init
  
  desc "init", "Setup rcomp test directory based on current configuration"

  def init

    write_config_file
    create_test_directories
    say "RComp successfully initialized", :green
  end

  # -e

  desc "set_executable EXECUTABLE_PATH", "Set the path to the executable RComp will test"
  method_option :overwrite,
    type: :boolean,
    default: false,
    aliases: "-O",
    desc: "Overwrite the current executable path"

  def set_executable

  end

  # -d
  
  desc "set_tests_directory TESTS_DIRECTORY_PATH", "Set the tests directory that RComp will run tests from"
  method_option :overwrite,
    type: :boolean,
    default: false,
    aliases: "-O",
    desc: "Overwrite the current test directory path"

  def set_tests_directory
    
  end

  # test

  desc "test TEST_NAME", "Run specified test"
  method_option :verbose,
    :type => :boolean,
    :default => false,
    :aliases => "-v",
    :desc => "toggle verbose output"

  def test(name)
    require_executable_path
    require_tests_root_path
  end

  # test-all

  desc "test-all", "Run all tests"
  method_option :verbose,
    :type => :boolean,
    :default => false,
    :aliases => "-v",
    :desc => "Toggle verbose output"

  def test_all
    require_executable_path
    require_tests_root_path
  end

  # gen
  
  desc "gen TEST_NAME", "Generate expected output for one or more tests"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :alieas => "-O",
    :desc => "Overwrite expected output file for test if present"

  def gen(test_name)
    require_executable_path
    require_tests_root_path
  end

  # gen-all
  
  desc "gen-all", "Generate expected output for all tests without it"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :alieas => "-O",
    :desc => "Overwrite expected output file for all tests if present"

  def gen_all
    require_executable_path
    require_tests_root_path
  end

  # print

  desc "print TEST_NAME", "Print out the content of a test and its expected output"
  method_option :result,
    :type => :boolean,
    :default => false,
    :aliases => "-r",
    :desc => "Print out the test result in addition to the test content and expected output"

  def print(test_name)
    require_executable_path
    require_tests_root_path
  end

  # vdiff

  desc "vdiff TEST_NAME", "vimdiff a test's expected and actual result"

  def vdiff(test_name)
    require_executable_path
    require_tests_root_path
  end

  # implode

  desc "implode", "Remove all RComp files recursively"

  def implode
    
    unless File.exist?(tests_root_path) || File.exist?(config_path)
      say "Nothing to implode...", :red
      exit 1
    end
  
    say "This will destroy all RComp files including all tests. Are you sure...? (y/n)"
    confirm = STDIN.gets.chomp

    if confirm.downcase == "y"
      rm_rf tests_root_path
      rm config_path
      say "RComp imploded!", :green
    else
      say "Aborting RComp implode...", :red
      exit 1
    end
  end

  protected

  def config_keys
    @config_keys ||= ["tests_directory",
                      "executable"]
  end
  
  # Path getters

  def tests_root_path
    @tests_root_path ||= @config["tests_directory"]
  end

  def tests_path
    @tests_path ||= @config["tests_directory"] + "/tests"
  end

  def expected_path
    @expected_path ||= @config["tests_directory"] + "/expected"
  end

  def results_path
    @results_path ||= @config["tests_directory"] + "/results"
  end

  def executable_path
    @executable_path ||= @config["executable"]
  end

  def config_path
    @config_path ||= ".rcomp"
  end

  # File IO
  
  def write_config_file
    if File.exists? config_path
      config_file = File.open(config_path, "w")
    else
      config_file = File.new(config_path, "w")
      say "Initialized RComp config file at #{config_path}"
    end

    config_file.puts YAML.dump @config
  end

  def create_test_directories
    mkdir tests_root_path
    mkdir tests_path
    mkdir expected_path
    mkdir results_path
  end

  # Error checking
  
  def require_executable_path
    unless executable_path
      say "No executable path present. RComp needs the path to an executable to test.", :red
      say "Run rcomp config -e EXECUTABLE_PATH to add your executable path.", :red
      exit 1
    end

    unless File.exists? executable_path
      say "Executable doesn't exist at path #{executable_path}.", :red
      say "Run rcomp config -e EXECUTABLE_PATH to add your executable path.", :red
      exit 1
    end
  end

  def require_tests_root_path
    unless tests_root_path
      say "No test directory path present.", :red
      say "Run rcomp config -d TESTS_PATH to specify where rcomp should store tests.", :red
      exit 1
    end

    unless File.exists? test_root_path
      say "Tests file doesn't exist at path #{test_root_path}.", :red
      say "Run rcomp init to create the directory at #{test_root_path}.", :red
    end
  end
end
