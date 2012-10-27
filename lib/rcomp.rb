require 'thor'
require 'psych'

###
# = Overview
#
# RComp is a simple test framework for testing command line applications 
# that require an input file. The tool was designed for testing programming
# languages but has a wide array of uses.

class RComp < Thor

  def initialize(args=[], options={}, config={})
    super
    
    load_default_config

    if config_file_exists?
      config_file = Psych.load(File.open('.rcomp'))

      if config_file
        config_file.each do |key, value|
          @config[key] = value if config_keys.include?(key)
        end
      end
    end
  end

  # init
  
  desc "init EXECUTABLE_PATH", "Setup RComp to test specified executable"

  def init(executable_path)

    if test_directory_exists?
      say "RComp test directory already exists at #{@config["directory"]}", :red
      exit 1
    end

    if config_file_exists?
      say "RComp config file already exists", :red
      exit 1
    end

    unless File.exists?(executable_path)
      say "Cant find #{File.expand_path(executable_path)}", :red
      exit 1
    end

    @config["executable"] = executable_path

    write_config_file
    create_test_directories
    say "RComp successfully initialized", :green
  end

  # test

  desc "test TEST_NAME", "Run specified test"
  method_option :verbose,
    :type => :boolean,
    :default => false,
    :aliases => "-v",
    :desc => "toggle verbose output"

  def test(name)

    unless test_directory_exists? && config_file_exists?
      say "RConf isn't set up properly. Run rconf init EXECUTABLE_NAME first.", :red
      exit 1
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
    puts "test-all #{options.inspect}"
  end

  # gen
  
  desc "gen TEST_NAME", "Generate expected output for one or more tests"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :alieas => "-O",
    :desc => "Overwrite expected output file for test if present"

  def gen(test_name)
    puts "gen #{options.inspect}"
  end

  # gen-all
  
  desc "gen-all", "Generate expected output for all tests without it"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :alieas => "-O",
    :desc => "Overwrite expected output file for all tests if present"

  def gen_all
    puts "gen-all #{options.inspect}"
  end

  # print

  desc "print TEST_NAME", "Print out the content of a test and its expected output"
  method_option :result,
    :type => :boolean,
    :default => false,
    :aliases => "-r",
    :desc => "Print out the test result in addition to the test content and expected output"

  def print(test_name)
    puts "print #{options.inspect}"
  end

  # vdiff

  desc "vdiff TEST_NAME", "vimdiff a test's expected and actual result"

  def vdiff(test_name)
    puts "vdiff #{options.inspect}"
  end

  # implode

  desc "implode", "Remove all RComp files recursively"

  def implode
    
    unless test_directory_exists? || config_file_exists?
      say "Nothing to implode...", :red
      exit 1
    end
  
    say "This will destroy all RComp files. Are you sure...? (y/n)"
    confirm = STDIN.gets.chomp

    if confirm.downcase == "y"
      system "rm -rf #{@config["directory"]}" if test_directory_exists?
      system "rm .rcomp" if config_file_exists?
      say "RComp imploded!", :green
    else
      say "Aborting RComp implode...", :red
      exit 1
    end
  end

  protected

  def config_keys
    @config_keys ||= ["directory",
                      "executable"]
  end

  def load_default_config
    @config = {}
    @config["directory"] = File.absolute_path('rcomp')
  end

  def test_directory_exists?
    File.exist?(@config["directory"])
  end

  def config_file_exists?
    File.exist?('.rcomp')
  end

  def write_config_file
    if config_file_exists?
      config_file = File.open(".rcomp", "w")
    else
      config_file = File.new(".rcomp", "w")
      say "Initialized RComp config file at #{File.expand_path(".config")}"
    end

    config_file.puts Psych.dump(@config)
  end

  def create_test_directories
    system "mkdir #{@config["directory"]}"
    system "mkdir #{@config["directory"]}/tests"
    system "mkdir #{@config["directory"]}/expected"
    system "mkdir #{@config["directory"]}/results"
    say "Initialized empty test directory at #{@config["directory"]}"
  end
end
