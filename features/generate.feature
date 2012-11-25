Feature: Generate
  Users should have the ability to generate expected output for tests

  # faulty configuration
  Scenario: Generate without command
    When I run `rcomp generate`
    Then the output should contain "No command present"
    And the exit status should be 1

  Scenario: Generate without init
    Given a file named ".rcomp" with:
      """
      command: ./test_exec

      """
    When I run `rcomp generate`
    Then the output should contain "No RComp directory"
    And the exit status should be 1

  Scenario: Generate with partial init
    Given a file named ".rcomp" with:
      """
      command: ./test_exec

      """
    And a directory named "rcomp"
    And a directory named "rcomp/tests"
    When I run `rcomp generate`
    Then the output should contain "Missing RComp directories"
    And the exit status should be 1

  # no tests
  @basic-conf
  Scenario: Generate with no tests
    When I run `rcomp generate`
    Then the output should contain "0 files ()"
    And the exit status should be 0

  # stdout single generate
  @basic-conf
  Scenario: Generate a single result
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    When I run `rcomp generate`
    Then the output should contain "1 file (1 generated)"
    And the file "rcomp/expected/test1.out" should contain "ABC"
    And the exit status should be 0

  @basic-conf
  Scenario: Skip a single result
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      DEF 

      """
    When I run `rcomp generate`
    Then the output should contain "1 file (1 skipped)"
    And the file "rcomp/expected/test1.out" should contain "DEF"
    And the exit status should be 0

  @basic-conf
  Scenario: Overwrite a single result
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      DEF

      """
    When I run `rcomp generate -O` interactively
    And I type "y"
    Then the output should contain "overwrite all existing" 
    And the output should contain "1 file (1 generated)"
    And the file "rcomp/expected/test1.out" should contain "ABC"
    And the exit status should be 0

  # stdout multiple generate
  @basic-conf
  @load-assorted-tests
  Scenario: Generate multiple results
    When I run `rcomp generate`
    Then the output should contain "3 files (2 skipped, 1 generated)"
    And the file "rcomp/expected/test_a.out" should contain "ABC"
    And the file "rcomp/expected/dir/test_b.out" should contain "XYZ"
    And the file "rcomp/expected/dir/foo/test_c.out" should contain "GHI"
    And the exit status should be 0

  @basic-conf
  @load-assorted-tests
  Scenario: Overwrite multiple results
    When I run `rcomp generate -O` interactively
    And I type "y"
    Then the output should contain "overwrite all existing" 
    And the file "rcomp/expected/test_a.out" should contain "ABC"
    And the file "rcomp/expected/dir/test_b.out" should contain "DEF"
    And the file "rcomp/expected/dir/foo/test_c.out" should contain "GHI"
    And the output should contain "3 files (3 generated)"
    And the exit status should be 0

  # stderr single generate
  @err-conf
  Scenario: Generate a single err result
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    When I run `rcomp generate`
    Then the output should contain "1 file (1 generated)"
    And the file "rcomp/expected/test1.err" should contain "ABC"
    And the exit status should be 0

  @err-conf
  Scenario: Skip a single err result
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.err" with:
      """
      XYZ

      """
    When I run `rcomp generate`
    Then the output should contain "1 file (1 skipped)"
    And the file "rcomp/expected/test1.err" should contain "XYZ"
    And the exit status should be 0

  @err-conf
  Scenario: Overwrite a single err result
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.err" with:
      """
      XYZ

      """
    When I run `rcomp generate -O` interactively
    And I type "y"
    Then the output should contain "1 file (1 generated)"
    And the file "rcomp/expected/test1.err" should contain "ABC"
    And the exit status should be 0

  # stderr multiple generate
  @err-conf
  @load-assorted-err-tests
  Scenario: Generate multiple err results
    When I run `rcomp generate`
    Then the output should contain "3 files (2 skipped, 1 generated)"
    And the file "rcomp/expected/test_a.err" should contain "ABC"
    And the file "rcomp/expected/dir/test_b.err" should contain "XYZ"
    And the file "rcomp/expected/dir/foo/test_c.err" should contain "GHI"
    And the exit status should be 0

  @err-conf
  @load-assorted-err-tests
  Scenario: Overwrite multiple err results
    When I run `rcomp generate -O` interactively
    And I type "y"
    Then the output should contain "3 files (3 generated)"
    And the output should contain "overwrite all existing"
    And the file "rcomp/expected/test_a.err" should contain "ABC"
    And the file "rcomp/expected/dir/test_b.err" should contain "DEF"
    And the file "rcomp/expected/dir/foo/test_c.err" should contain "GHI"
    And the exit status should be 0

  # alias
  @basic-conf
  @load-assorted-tests
  Scenario: Generate alias g
    When I run `rcomp g`
    Then the output should contain "3 files (2 skipped, 1 generated)"
    And the file "rcomp/expected/test_a.out" should contain "ABC"
    And the file "rcomp/expected/dir/test_b.out" should contain "XYZ"
    And the file "rcomp/expected/dir/foo/test_c.out" should contain "GHI"
    And the exit status should be 0

  # filters
  @basic-conf
  @load-assorted-tests
  Scenario: Generate with filter: catches all
    When I run `rcomp generate --grep=test`
    Then the output should contain "3 files (2 skipped, 1 generated)"
    And the exit status should be 0

  @basic-conf
  @load-assorted-tests
  Scenario: Generate with filter: catches some
    When I run `rcomp generate --grep=dir`
    Then the output should contain "2 files (1 skipped, 1 generated)"
    And the exit status should be 0

  @basic-conf
  @load-assorted-tests
  Scenario: Generate with filter: catches none
    When I run `rcomp generate --grep=xyz`
    Then the output should contain "0 files ()"
    And the exit status should be 0

  @basic-conf
  @load-assorted-tests
  Scenario: Generate with filter: catches some with overwrite
    When I run `rcomp generate -O --grep=dir` 
    Then the output should contain "2 files (2 generated)"
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
    When I run `rcomp g`
    Then the output should contain "3 files (2 skipped, 1 generated)"
    And the exit status should be 0

  @basic-conf
  @load-assorted-tests
  Scenario: Test with config ignore filter set: catches some
    Given I append to ".rcomp" with:
      """
      ignore:
        - foo

      """
    When I run `rcomp g`
    Then the output should contain "2 files (2 skipped)"
    And the exit status should be 0

  @basic-conf
  @load-assorted-tests
  Scenario: Test with config ignore filter set: catches none
    Given I append to ".rcomp" with:
      """
      ignore:
        - test

      """
    When I run `rcomp g`
    Then the output should contain "0 files ()"
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
    When I run `rcomp g`
    Then the output should contain "1 file (1 generated)"
    And the exit status should be 0

  # custom generate directory
  @custom-conf
  Scenario: Custom conf generate
    Given a file named "test/integration/rcomp/tests/test1.test" with:
      """
      ABC

      """
    When I run `rcomp generate`
    Then the output should contain "1 file (1 generated)"
    And the exit status should be 0

  # system files
  @basic-conf
  Scenario: Generate with system files
    Given a file named "rcomp/tests/.DS_Store" with:
      """
      some data

      """
    When I run `rcomp generate`
    Then the output should contain "0 files ()"
    And the exit status should be 0

  @basic-conf
  @load-assorted-tests
  Scenario: Generate with multiple tests and system files
    Given a file named "rcomp/tests/.DS_Store" with:
      """
      some data

      """
    And a file named "rcomp/tests/dir/.DS_Store" with:
      """
      some more data

      """
    When I run `rcomp generate`
    Then the output should contain "3 files (2 skipped, 1 generated)"
    And the exit status should be 0

  # timeout
  @loop-conf
  Scenario: Test hanging test with default timeout
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    When I run `rcomp generate` for up to 6 seconds
    Then the output should contain "1 file (1 failed)"
    And the output should contain "timeout : /test1"
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
    When I run `rcomp generate` for up to 2 seconds
    Then the output should contain "1 file (1 failed)"
    And the output should contain "timeout : /test1"
    And the exit status should be 1
