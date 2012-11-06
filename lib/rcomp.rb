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
  autoload :Helper, 'rcomp/helper'

  include RComp::Actions
  include RComp::Conf
  include RComp::Test
  include RComp::Helper

  def initialize(args=[], options={}, config={})
    super
    load_conf
  end

  # init
  
  desc "init", "Setup rcomp test directory based on current configuration"

  def init
    require_tests_root_path

    if initialized?
      say "RComp already initialized", :yellow
      exit 1
    end

    create_test_directories
    
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
        say "executable key exists in config file", :red
        say "Run rcomp -e -O PATH to overwrite", :red
        exit 1
      end
    end

    set_executable_path path
    write_conf
    say "Rcomp successfully set executable path to #{executable_path}", :green
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
        say "tests_directory key exists in config file", :red
        say "Run rcomp -d -O PATH to overwrite", :red
        exit 1
      end
    end

    set_tests_root_path path
    write_conf
    say "RComp successfully set tests directory path to #{tests_root_path}", :green
  end

  # test

  desc "test PATH", "Run specified test or test directory"

  def test(path)
    require_basic_conf

    # NOTE: Add logic for ignoring file extensions here
    # It could go elsewhere, possibly in a module
    
    test = tests_path + path
    run_tests test
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
  
  desc "gen PATH", "Generate expected output for test(s)"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :aliases => "-O",
    :desc => "Overwrite expected output file for test if present"

  def gen(path)
    require_basic_conf
    
    # NOTE: Add logic for ignoring file extensions here
    # It could go elsewhere, possibly in a module

    test = tests_path + path
    run_tests test, true, @options[:overwrite]
  end

  # gen-all
  
  desc "gen-all", "Generate expected output for all tests without it"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :aliases => "-O",
    :desc => "Overwrite expected output file for all tests if present"

  def gen_all
    require_basic_conf
    run_tests tests_path, true, @options[:overwrite]
  end

  # vdiff

  desc "vdiff TEST_NAME", "vimdiff a test's expected and actual result"

  def vdiff(name)
    require_basic_conf

    result = output_path(results_path + name)
    expected = output_path(expected_path + name)

    unless File.exists? result
      say "No result for test #{name}", :red
      exit 1
    end

    unless File.exist? expected
      say "No expected output for test #{name}", :red
      exit 1
    end

    system "vimdiff #{expected} #{result}"
  end

  # implode

  desc "implode", "Remove ALL RComp files including tests"

  def implode

    unless File.exists? conf_path
      say "Nothing to implode", :red
      exit 1
    end
  
    puts "This will destroy all RComp files including all tests."
    print "Are you sure? (Y/N) "
    confirm = STDIN.gets.chomp

    if confirm.downcase == "y"
      rm_rf tests_root_path if tests_root_path
      rm conf_path
      say "RComp imploded!", :green
    else
      say "Aborting RComp implode...", :red
      exit 1
    end
  end

  private

  def create_test_directories
    mkdir tests_root_path
    mkdir tests_path
    mkdir expected_path
    mkdir results_path
  end
end
