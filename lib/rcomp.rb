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

    test_path = tests_path + name

    unless File.exists? test_path
      say "Test #{test_path} not found", :red
      exit 1
    end

    if File.directory? test_path
      run_tests test_path
    else
      if run_test(test_path)
        say "\nAll tests passed!\n", :green
      else
        puts "\n"
        exit 1
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
    run_tests tests_path
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
    
    rel_path = path.gsub(tests_path, '')

    expected = output_path(expected_path + rel_path)
    result = output_path(results_path + rel_path)
    
    return test_stubbed(rel_path) unless File.exists?(expected)

    FileUtils.mkpath(File.dirname(result)) unless File.exists?(result)

    system "#{executable_path} #{path} > #{result}"

    FileUtils.identical?(expected, result) ? 
      test_passed(rel_path) : test_failed(rel_path)
  end

  def run_tests(directory)

    say "Running all tests in #{directory}\n\n"

    passed = 0
    failed = 0

    Find.find(directory) do |path|
      if FileTest.directory?(path)
        next
      else
        run_test(path) ? passed += 1 : failed += 1
      end
    end

    if failed > 0
      say "\nFailed #{failed} #{failed > 1 ? "tests" : "test"}\n", :red
      exit 1
    else
      say "\nAll tests passed!\n", :green
    end
  end

  def test_stubbed(path)
    say "Missing expected output for #{path}", :yellow
    return false
  end

  def test_passed(path)
    say "Passed #{path}", :green
    return true
  end

  def test_failed(path)
    say "Failed #{path}", :red
    return false
  end

  def output_path(path)
    File.dirname(path) + '/' + File.basename(path, '.*') + '.out'
  end

  def create_test_directories
    mkdir tests_root_path
    mkdir tests_path
    mkdir expected_path
    mkdir results_path
  end
end
