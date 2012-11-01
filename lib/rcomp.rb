require 'thor'
require 'yaml'
require 'find'

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
  autoload :Conf, 'rcomp/conf'
  autoload :Test, 'rcomp/test'

  include RComp::Actions
  include RComp::Conf
  include RComp::Test

  def initialize(args=[], options={}, config={})
    super
    load_conf
  end

  # init
  
  desc "init", "Setup rcomp test directory based on current configuration"

  def init
    require_tests_root_path
    create_test_directories

    ## FIX: add logic to check if all files already exist
    
    say "RComp successfully initialized", :green
  end

  # -e

  desc "set_executable PATH", "Set the path to the executable RComp will test"
  method_option :overwrite,
    type: :boolean,
    default: false,
    aliases: "-O",
    desc: "Overwrite the current executable path"

  def set_executable(path)

    if executable_path
      unless @options[:overwrite]
        say "executable key exists in config file.", :red
        say "Run rcomp -e -O PATH to overwrite.", :red
        exit 1
      end
    end

    set_executable_path path
    write_conf
    say "Rcomp successfully set executable path to #{executable_path}.", :green
  end

  # -d
  
  desc "set_tests_directory PATH", "Set the tests directory that RComp will run tests from"
  method_option :overwrite,
    type: :boolean,
    default: false,
    aliases: "-O",
    desc: "Overwrite the current test directory path"

  def set_tests_directory(path)

    if tests_root_path
      unless @options[:overwrite]
        say "tests_directory key exists in config file.", :red
        say "Run rcomp -d -O PATH to overwrite.", :red
        exit 1
      end
    end

    set_tests_root_path path
    write_conf
    say "RComp successfully set tests directory path to #{tests_root_path}.", :green
  end

  # test

  desc "test PATH", "Run specified test or test directory"
  method_option :verbose,
    :type => :boolean,
    :default => false,
    :aliases => "-v",
    :desc => "toggle verbose output"

  def test(name)
    require_basic_conf

    Find.find(tests_path) do |path|
      if File.basename(path, ".*") == name
        if FileTest.directory?(path)
           
        else

        end
      end
    end
  end

  # test-all

  desc "test-all", "Run all tests"
  method_option :verbose,
    :type => :boolean,
    :default => false,
    :aliases => "-v",
    :desc => "Toggle verbose output"

  def test_all
    require_basic_conf
    
    tests = []
    
    # Find all tests in the tests directory
    Find.find(tests_path) do |path|
      if FileTest.directory?(path)
        if ignored_directory? File.basename(path)[0]
          Find.prune # Don't look any further into this directory.
        else
          next
        end
      else
        tests << path
      end
    end

    failed = 0
    passed = 0

    tests.each do |test|
      test_path = test.gsub(tests_path, '')
      run_test test_path
      if test_passed? test_path
        say "Passed: #{test_path.slice(0)}", :green
        passed += 1
      else
        say "Failed: #{test_path.slice(0)}", :red
        failed += 1
      end
    end

    say "Passed #{passed} tests", :green
    say "Failed #{failed} tests", :red
  end

  # gen
  
  desc "gen TEST_NAME", "Generate expected output for one or more tests"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :alieas => "-O",
    :desc => "Overwrite expected output file for test if present"

  def gen(test_name)
    require_basic_conf
  end

  # gen-all
  
  desc "gen-all", "Generate expected output for all tests without it"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :alieas => "-O",
    :desc => "Overwrite expected output file for all tests if present"

  def gen_all
    require_basic_conf
  end

  # print

  desc "print TEST_NAME", "Print out the content of a test and its expected output"
  method_option :result,
    :type => :boolean,
    :default => false,
    :aliases => "-r",
    :desc => "Print out the test result in addition to the test content and expected output"

  def print(test_name)
    require_basic_conf
  end

  # vdiff

  desc "vdiff TEST_NAME", "vimdiff a test's expected and actual result"

  def vdiff(test_name)
    require_basic_conf
  end

  # implode

  desc "implode", "Remove all RComp files recursively"

  def implode

    unless File.exists? conf_path
      say "Nothing to implode", :red
      say "Aborting...", :red
      exit 1
    end
  
    say "This will destroy all RComp files including all tests. Are you sure...? (y/n)"
    confirm = STDIN.gets.chomp

    if confirm.downcase == "y"
      rm_rf tests_root_path if tests_root_path
      rm conf_path if conf_path
      say "RComp imploded!", :green
    else
      say "Aborting RComp implode...", :red
      exit 1
    end
  end

  private

  # Testing
  
  def run_test(path)
    unless result_file_exists? path
      FileUtils.mkpath(File.expand_path(results_path + path))
    end

    puts "#{executable_path} #{tests_path + path} > #{results_path + path}"
  end

  def run_tests(directory)
    
  end

  def test_passed?(path)
    unless expected_file_exists? path
      say "No expected output for test #{path}.", :red
      say "Create one manually or run rcomp gen #{path}.", :red
      return false
    end

    if File.identical?(results_path + path, expected_path + path)
      true
    else
      false
    end
  end

  def expected_file_exists?(path)
    File.exists?(expected_path + path)
  end

  def result_file_exists?(path)
    File.exists?(results_path + path)
  end
  
  def create_test_directories
    mkdir tests_root_path
    mkdir tests_path
    mkdir expected_path
    mkdir results_path
  end
end
