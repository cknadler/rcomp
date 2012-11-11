require 'thor'
require 'yaml'
require 'find'

###
# = Overview
#
# RComp is a simple test framework for testing command line applications 
# that require an input file. The tool was designed for testing programming
# languages.

class RComp < Thor
  map "-e" => :set_executable
  map "-d" => :set_tests_directory

  autoload :Actions, 'rcomp/actions'
  autoload :Conf, 'rcomp/conf'
  autoload :Test, 'rcomp/test'
  autoload :Helper, 'rcomp/helper'
  autoload :Path, 'rcomp/path'

  include RComp::Actions
  include RComp::Conf
  include RComp::Test
  include RComp::Helper
  include RComp::Path

  def initialize(args=[], options={}, config={})
    super
    load_conf
  end

  # init
  
  desc "init", "Setup rcomp test directory based on current configuration"

  def init
    require_root_path

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
        say "Executable path exists. Run rcomp -e -O PATH to overwrite", :red
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

    if root_path
      unless @options[:overwrite]
        say "Test directory path exists. Run rcomp -e -O PATH to overwrite", :red
        exit 1
      end
    end

    set_root_path path
    write_conf
    say "RComp successfully set tests directory path to #{root_path}", :green
  end

  # test

  desc "test PATH", "Run specified test or test directory"

  def test(path)
    require_basic_conf
    run_tests find_test_path(path)
  end

  # test-all

  desc "test-all", "Run all tests"

  def test_all
    require_basic_conf
    run_tests test_root_path
  end

  # gen
  
  desc "gen PATH", "Generate expected output for test(s)"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :aliases => "-O",
    :desc => "Overwrite expected output file for test if present"

  def generate(path)
    require_basic_conf
    run_tests find_test_path(path), true, @options[:overwrite]
  end

  # gen-all
  
  desc "gen-all", "Generate expected output for all tests without it"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :aliases => "-O",
    :desc => "Overwrite expected output file for all tests if present"

  def generate_all
    require_basic_conf

    if @options[:overwrite]
      say "This will overwrite all existing expected results."
      print "Are you sure? (Y/N) "
      confirm = STDIN.gets.chomp

      unless confirm.downcase == 'y'
        say "Aborting gen-all...", :red
        exit 1
      end
    end

    run_tests test_root_path, true, @options[:overwrite]
  end

  # vdiff

  desc "vdiff TEST_NAME", "vimdiff a test's expected and actual result"

  def vdiff(path)
    require_basic_conf

    rel_path = relative_path(find_test_path path)
    result = output_path(result_root_path + rel_path)
    expected = output_path(expected_root_path + rel_path)

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
      say 'Nothing to implode', :red
      exit 1
    end
  
    puts 'This will destroy all RComp files including all tests.'
    print 'Are you sure? (Y/N) '
    confirm = STDIN.gets.chomp

    if confirm.downcase == 'y'
      rm_rf test_root_path if root_path
      rm conf_path
      say 'RComp imploded!', :green
    else
      say 'Aborting implode...', :red
      exit 1
    end
  end

  private

  def create_test_directories
    mkdir root_path
    mkdir test_root_path
    mkdir expected_root_path
    mkdir result_root_path
  end
end
