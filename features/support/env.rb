require 'rcomp'
require 'aruba/api'
require 'aruba/cucumber'
require 'test/unit/assertions'

# Helpers
def create_executable(content)
  write_file("test_exec", content)
  in_current_dir do
    FileUtils.chmod(0755, "test_exec")
  end
end

def basic_executable
  "#!/usr/bin/env ruby\nputs IO.binread(ARGV[0])"
end

def err_executable
  "#!/usr/bin/env ruby\n$stderr.puts IO.binread(ARGV[0])"
end

def loop_executable
  "!#/usr/bin/env ruby\nsleep 30"
end

def create_assorted_tests
  write_file("rcomp/tests/test_a.test", "ABC\n")
  write_file("rcomp/tests/dir/test_b.test", "DEF\n")
  write_file("rcomp/tests/dir/foo/test_c.test", "GHI\n")
end

# Custom Tags
Before('@basic-conf') do
  create_executable(basic_executable)
  # Spin up basic RComp configuration
  write_file(".rcomp", "command: ./test_exec\n")
  run_simple('rcomp init')
end

Before('@err-conf') do
  create_executable(err_executable)
  # Spin up RComp configuraton with an erroring executable
  write_file(".rcomp", "command: ./test_exec\n")
  run_simple('rcomp init')
end

Before('@custom-conf') do
  create_executable(basic_executable)
  # Spin up custom path RComp configuration
  write_file(".rcomp", 
             "command: ./test_exec\ndirectory: test/integration/rcomp\n")
  run_simple('rcomp init')
end

Before('@loop-conf') do
  create_executable(loop_executable)
  write_file(".rcomp", "command: ./test_exec\n")
  run_simple('rcomp init')
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
