require 'thor'

class RComp < Thor

  def initialize(args=[], options={}, config={})
    super
    
    @config = {}
    @config[:directory] = File.expand_path('rcomp')

    if config_file_exists?
      # read and store in config hash
    end
  end

  # init
  
  desc "init", "setup rcomp structure in current directory"

  def init
    unless rcomp_exists?
      system "mkdir #{@config[:directory]}"
      system "mkdir #{@config[:directory]}/tests"
      system "mkdir #{@config[:directory]}/expected"
      system "mkdir #{@config[:directory]}/results"
      say "rcomp initialized in #{@config[:directory]}", :green
    else
      say "rcomp already exists at #{@config[:directory]}", :red
      exit 1
    end
  end

  # test

  desc "test TEST_NAME", "run specified test"
  method_option :verbose,
    :type => :boolean,
    :default => false,
    :aliases => "-v",
    :desc => "toggle verbose output"

  def test(name)
    puts "test #{options.inspect}"
  end

  # test-all

  desc "test-all", "run all tests"
  method_option :verbose,
    :type => :boolean,
    :default => false,
    :aliases => "-v",
    :desc => "toggle verbose output"

  def test_all
    puts "test-all #{options.inspect}"
  end

  # gen
  
  desc "gen TEST_NAME", "generate expected output for one or more tests"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :alieas => "-O",
    :desc => "overwrite expected output file for test if present"

  def gen(name)
    puts "gen #{options.inspect}"
  end

  # gen-all
  
  desc "gen-all", "generate expected output for all tests without it"
  method_option :overwrite,
    :type => :boolean,
    :default => false,
    :alieas => "-O",
    :desc => "overwrite expected output file for all tests if present"

  def gen_all
    puts "gen-all #{options.inspect}"
  end

  # print

  desc "print TEST_NAME", "print out the content of a test and its expected output"
  method_option :result,
    :type => :boolean,
    :default => false,
    :aliases => "-r",
    :desc => "print out the test result in addition to the test content and expected output"

  def print(name)
    puts "print #{options.inspect}"
  end

  # vdiff

  desc "vdiff TEST_NAME", "vimdiff a test's expected and actual result"

  def vdiff(name)
    puts "vdiff #{options.inspect}"
  end

  protected

  def rcomp_exists?
    File.exist?(@config[:directory])
  end

  def config_file_exists?
    File.exist?('.rcomp')
  end
end
