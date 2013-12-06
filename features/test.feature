Feature: Test
  Users should have the ability to run tests

  # faulty configuration
  Scenario: Test without command
    When I run `rcomp test`
    Then the output should contain "No command present"
    And the exit status should be 1

  Scenario: Test without init
    Given a file named ".rcomp" with:
      """
      command: ./test_exec

      """
    When I run `rcomp test`
    Then the output should contain "No RComp directory"
    And the exit status should be 1

  Scenario: Test with partial init
    Given a file named ".rcomp" with:
      """
      command: ./test_exec

      """
    And a directory named "rcomp"
    And a directory named "rcomp/tests"
    When I run `rcomp test`
    Then the output should contain "Missing RComp directories"
    And the exit status should be 1
  
  # no tests
  @basic-conf
  Scenario: Test with no tests
    When I run `rcomp test`
    Then the output should contain "0 tests ()"
    And the exit status should be 0

  # stdout single test
  @basic-conf
  Scenario: Test with single test passing
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      ABC

      """
    When I run `rcomp test`
    Then the output should contain "1 test (1 passed)"
    And the exit status should be 0

  @basic-conf
  Scenario: Test with single test and no results directory
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      ABC

      """
    When I remove the directory "rcomp/results"
    Then a directory named "rcomp/results" should not exist
    When I run `rcomp test`
    Then a directory named "rcomp/results" should exist
    And the exit status should be 0

  @basic-conf
  Scenario: Test with single test skipped
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    When I run `rcomp test`
    Then the output should contain "Skipped 1 test"
    And the output should contain "Run rcomp generate"
    And the output should contain "1 test (1 skipped)"
    And the exit status should be 0

  @basic-conf
  Scenario: Test with single test failing
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      XYZ

      """
    When I run `rcomp test`
    Then the output should contain "failed : test1.test (out)"
    And the output should contain "1 test (1 failed)"
    And the exit status should be 1

  # stdout multiple tests
  @basic-conf
  @load-assorted-tests
  Scenario: Test multiple
    When I run `rcomp test`
    Then the output should contain "3 tests (1 failed, 1 skipped, 1 passed)"
    And the exit status should be 1

  # stderr single test
  @err-conf
  Scenario: Test err with single test passing
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.err" with:
      """
      ABC

      """
    When I run `rcomp test`
    Then the output should contain "1 test (1 passed)"
    And the exit status should be 0

  @err-conf
  Scenario: Test err with single test failing
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.err" with:
      """
      XYZ

      """
    When I run `rcomp test`
    Then the output should contain "failed : test1.test (err)"
    And the output should contain "1 test (1 failed)"
    And the exit status should be 1

  # stderr multiple tests
  @err-conf
  @load-assorted-err-tests
  Scenario: Test multiple err: passing, skipped and failing
    When I run `rcomp test`
    Then the output should contain "3 tests (1 failed, 1 skipped, 1 passed)"
    And the exit status should be 1

  # stderr + stdout tests
  @basic-conf
  Scenario: Single test, failing both err and out
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      XYZ

      """
    And a file named "rcomp/expected/test1.err" with:
      """
      XYZ

      """
    When I run `rcomp test`
    Then the output should contain "failed : test1.test (out, err)"
    And the output should contain "1 test (1 failed)"
    And the exit status should be 1

  # alias
  @basic-conf
  @load-assorted-tests
  Scenario: Test alias t
    When I run `rcomp t`
    Then the output should contain "3 tests (1 failed, 1 skipped, 1 passed)"
    And the exit status should be 1

  # filters
  @basic-conf
  @load-assorted-tests
  Scenario: Test with filter: catches all
    When I run `rcomp test --grep=test`
    Then the output should contain "3 tests (1 failed, 1 skipped, 1 passed)"
    And the exit status should be 1

  @basic-conf
  @load-assorted-tests
  Scenario: Test with filter: catches some
    When I run `rcomp t --grep=dir`
    Then the output should contain "2 tests (1 failed, 1 skipped)"
    And the exit status should be 1

  @basic-conf
  @load-assorted-tests
  Scenario: Test with filter: catches none
    When I run `rcomp t --grep=xyz`
    Then the output should contain "0 tests ()"
    And the exit status should be 0

  # ignore from config
  @basic-conf
  @load-assorted-tests
  Scenario: Test with config ignore filter set: catches all
    Given I append to ".rcomp" with:
      """
      ignore:
        - xyz
      
      """
    When I run `rcomp t`
    Then the output should contain "3 tests (1 failed, 1 skipped, 1 passed)"
    And the exit status should be 1

  @basic-conf
  @load-assorted-tests
  Scenario: Test with config ignore filter set: catches some
    Given I append to ".rcomp" with:
      """
      ignore:
        - foo

      """
    When I run `rcomp t`
    Then the output should contain "2 tests (1 failed, 1 passed)"
    And the exit status should be 1

  @basic-conf
  @load-assorted-tests
  Scenario: Test with config ignore filter set: catches none
    Given I append to ".rcomp" with:
      """
      ignore:
        - test

      """
    When I run `rcomp t`
    Then the output should contain "0 tests ()"
    And the exit status should be 0

  @basic-conf
  @load-assorted-tests
  Scenario: Test with multiple config ignore filters set
    Given I append to ".rcomp" with:
      """
      ignore:
        - test_a
        - test_b

      """
    When I run `rcomp t`
    Then the output should contain "1 test (1 skipped)"
    And the exit status should be 0

  # custom tests directory
  @custom-conf
  Scenario: Custom conf test
    Given a file named "test/integration/rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "test/integration/rcomp/expected/test1.out" with:
      """
      ABC

      """
    When I run `rcomp test`
    Then the output should contain "1 test (1 passed)"
    And the exit status should be 0

  # system files
  @basic-conf
  Scenario: Test with system files
    Given a file named "rcomp/tests/.DS_Store" with:
      """
      some data

      """
    When I run `rcomp test`
    Then the output should contain "0 tests ()"
    And the exit status should be 0

  @basic-conf
  @load-assorted-tests
  Scenario: Test with multiple tests and system files
    Given a file named "rcomp/tests/.DS_Store" with:
      """
      some data

      """
    And a file named "rcomp/tests/dir/.DS_Store" with:
      """
      some more data

      """
    When I run `rcomp test`
    Then the output should contain "3 tests (1 failed, 1 skipped, 1 passed)"
    And the exit status should be 1

  # timeout
  @loop-conf
  Scenario: Test hanging test with default timeout
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      ABC

      """
    When I run `rcomp test` for up to 6 seconds
    Then the output should contain "1 test (1 failed)"
    And the output should contain "timeout : test1.test"
    And the exit status should be 1

  @loop-conf
  Scenario: Test hanging test with custom timeout
    Given I append to ".rcomp" with:
      """
      timeout: 1

      """
    And a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      ABC

      """
    When I run `rcomp test` for up to 2 seconds
    Then the output should contain "1 test (1 failed)"
    And the output should contain "timeout : test1.test"
    And the exit status should be 1
