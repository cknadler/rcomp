require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'rcomp'
require 'aruba/api'
require 'aruba/cucumber'
require 'test/unit/assertions'

# Custom Tags

Before('@basic-config') do

  # Create executable for testing
  content = "#!/usr/bin/env ruby\nputs IO.binread(ARGV[0])"

  write_file("test_exec", content)
  in_current_dir do
    FileUtils.chmod(0755, "test_exec")
  end

  # Spin up basic RComp configuration
  run_simple('rcomp -d rcomp', false)
  run_simple('rcomp -e ./test_exec', false)
  run_simple('rcomp init', false)
end

World(Test::Unit::Assertions)
