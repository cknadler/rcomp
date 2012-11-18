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

# Helpers
def create_executable
  content = "#!/usr/bin/env ruby\nputs IO.binread(ARGV[0])"
  write_file("test_exec", content)
  in_current_dir do
    FileUtils.chmod(0755, "test_exec")
  end
end

def create_err_executable
  content = "#!/usr/bin/env ruby\n$stderr.puts IO.binread(ARGV[0])"
  write_file("test_exec", content)
  in_current_dir do
    FileUtils.chmod(0755, "test_exec")
  end
end

def create_assorted_tests
  write_file("rcomp/tests/test_a.test", "ABC\n")
  write_file("rcomp/tests/dir/test_b.test", "DEF\n")
  write_file("rcomp/tests/dir/foo/test_c.test", "GHI\n")
end

# Custom Tags
Before('@basic-conf') do
  create_executable
  # Spin up basic RComp configuration
  run_simple('rcomp c ./test_exec', false)
  run_simple('rcomp init', false)
end

Before('@err-conf') do
  create_err_executable
  # Spin up RComp configuraton with an erroring executable
  run_simple('rcomp c ./test_exec', false)
  run_simple('rcomp init', false)
end

Before('@custom-conf') do
  create_executable
  # Spin up custom path RComp configuration
  run_simple('mkdir test', false)
  run_simple('mkdir test/integration', false)
  run_simple('rcomp d test/integration/rcomp')
  run_simple('rcomp c ./test_exec', false)
  run_simple('rcomp init', false)
end

Before('@load-assorted-tests') do
  create_assorted_tests
  write_file("rcomp/expected/test_a.out", "ABC\n")
  write_file("rcomp/expected/dir/test_b.out", "XYZ\n")
end

Before('@load-assorted-err-tests') do
  create_assorted_tests
  write_file("rcomp/expected/test_a.err", "ABC\n")
  write_file("rcomp/expected/dir/test_b.err", "XYZ\n")
end

World(Test::Unit::Assertions)
