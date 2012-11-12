Feature: Test
  Users should have the ability to run tests
  
  Scenario: Run single test
    Given an executable named "test_exec" with:
      """
      #!/usr/bin/env ruby
      puts IO.binread(ARGV[0])
      """
    And I run `rcomp -d rcomp`
    And I run `rcomp -e test_exec`
    And I run `rcomp init`
    And a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      ABC

      """
    When I run `rcomp test test1.test`
    Then the output should contain "1 test (1 passed)"
    And the exit status should be 0
  
  Scenario: Run a test with a subdir executable
    Given an executable named "src/test_exec" with:
      """
      #!/usr/bin/env ruby
      puts IO.binread(ARGV[0])
      """
    And I run `rcomp -d rcomp`
    And I run `rcomp -e src/test_exec`
    And I run `rcomp init`
    And a file named "rcomp/tests/test1.test" with:
      """
      ABC
      
      """
    And a file named "rcomp/expected/test1.out" with:
      """
      ABC

      """
    When I run `rcomp test test1.test`
    Then the output should contain "1 test (1 passed)"
    And the exit status should be 0

  Scenario: Fail a single test
    Given an executable named "test_exec" with:
      """
      #!/usr/bin/env ruby
      puts IO.binread(ARGV[0])
      """
    And I run `rcomp -d rcomp`
    And I run `rcomp -e test_exec`
    And I run `rcomp init`
    And a file named "rcomp/tests/test1.test" with:
      """
      ABC
      
      """
    And a file named "rcomp/expected/test1.out" with:
      """
      CBA

      """
    When I run `rcomp test test1.test`
    Then the output should contain "1 test (1 failed)"
    And the exit status should be 1

  Scenario: Run a test wihtout expected output
    Given an executable named "test_exec" with:
      """
      #!/usr/bin/env ruby
      puts IO.binread(ARGV[0])
      """
    And I run `rcomp -d rcomp`
    And I run `rcomp -e test_exec`
    And I run `rcomp init`
    And a file named "rcomp/tests/test1.test" with:
      """
      ABC
      
      """
    When I run `rcomp test test1.test`
    Then the output should contain "1 test (1 missing)"
    And the exit status should be 0 


  Scenario: Run a test directory
    Given an executable named "test_exec" with:
      """
      #!/usr/bin/env ruby
      puts IO.binread(ARGV[0])
      """
    And I run `rcomp -d rcomp`
    And I run `rcomp -e test_exec`
    And I run `rcomp init`
    And a file named "rcomp/tests/dir/test1.test" with:
      """
      ABC
      
      """
    And a file named "rcomp/tests/dir/test2.test" with:
      """
      DEF

      """
    And a file named "rcomp/expected/dir/test1.out" with:
      """
      ABC

      """
    And a file named "rcomp/expected/dir/test2.out" with:
      """
      DEF

      """
    When I run `rcomp test dir`
    Then the output should contain "2 tests (2 passed)"
    And the exit status should be 0

  Scenario: Run a test directory with subdirs
    Given an executable named "test_exec" with:
      """
      #!/usr/bin/env ruby
      puts IO.binread(ARGV[0])
      """
    And I run `rcomp -d rcomp`
    And I run `rcomp -e test_exec`
    And I run `rcomp init`
    And a file named "rcomp/tests/dir/test1.test" with:
      """
      ABC
      
      """
    And a file named "rcomp/tests/dir/subdir/test2.test" with:
      """
      DEF

      """
    And a file named "rcomp/expected/dir/test1.out" with:
      """
      ABC

      """
    And a file named "rcomp/expected/dir/subdir/test2.out" with:
      """
      DEF

      """
    When I run `rcomp test dir`
    Then the output should contain "2 tests (2 passed)"
    And the exit status should be 0

  Scenario: Run test on an invalid path
    Given an executable named "test_exec" with:
      """
      #!/usr/bin/env ruby
      puts IO.binread(ARGV[0])
      """
    And I run `rcomp -d rcomp`
    And I run `rcomp -e test_exec`
    And I run `rcomp init`
    When I run `rcomp test bad/path/name`
    Then the output should contain "No test"
    And the exit status should be 1

  Scenario: Test a directory with passing, failing and stubbed tests
    Given an executable named "test_exec" with:
      """
      #!/usr/bin/env ruby
      puts IO.binread(ARGV[0])
      """
    And I run `rcomp -d rcomp`
    And I run `rcomp -e test_exec`
    And I run `rcomp init`
    And a file named "rcomp/tests/dir/test1.test" with:
      """
      ABC
      
      """
    And a file named "rcomp/tests/dir/subdir/test2.test" with:
      """
      DEF

      """
    And a file named "rcomp/tests/dir/subdir/test3.test" with:
      """
      GHI

      """
    And a file named "rcomp/expected/dir/test1.out" with:
      """
      ABC

      """
    And a file named "rcomp/expected/dir/subdir/test2.out" with:
      """
      FED

      """
    When I run `rcomp test dir`
    Then the output should contain "3 tests (1 failed, 1 missing, 1 passed)"
    And the exit status should be 1
