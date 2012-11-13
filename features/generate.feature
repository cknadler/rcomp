Feature: Generate
  Users should have the ability to generate expected output for tests

  @basic-config
  Scenario: Generate for a single test
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC
      
      """
    When I run `rcomp generate test1.test`
    Then the output should contain "1 file (1 generated)"
    And the file "rcomp/expected/test1.out" should contain "ABC"
    And the exit status should be 0

  @basic-config
  Scenario: Generate without file extension
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC
      
      """
    When I run `rcomp generate test1`
    Then the output should contain "1 file (1 generated)"
    And the file "rcomp/expected/test1.out" should contain "ABC"
    And the exit status should be 0

  @basic-config
  Scenario: Generate with a bad path
    When I run `rcomp generate some/bad/path`
    Then the output should contain "No test"
    And the exit status should be 1

  @basic-config
  Scenario: Generate for a directory
    Given a file named "rcomp/tests/dir/test1.test" with:
      """
      ABC

      """
    Given a file named "rcomp/tests/dir/test2.test" with:
      """
      DEF

      """
    Given a file named "rcomp/tests/dir/subdir/test3.test" with:
      """
      GHI

      """
    When I run `rcomp generate dir`
    Then the output should contain "3 files (3 generated)"
    And the file "rcomp/expected/dir/test1.out" should contain "ABC"
    And the file "rcomp/expected/dir/test2.out" should contain "DEF"
    And the file "rcomp/expected/dir/subdir/test3.out" should contain "GHI"
    And the exit status should be 0

  @basic-config
  Scenario: Generate on single test with existing expected output
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    Given a file named "rcomp/expected/test1.out" with:
      """
      DEF

      """
    When I run `rcomp generate test1.test`
    Then the output should contain "1 file (1 skipped)"
    And the output should contain "Run rcomp generate -O PATH"
    And the file "rcomp/expected/test1.out" should contain "DEF"
    And the exit status should be 0

  @basic-config
  Scenario: Generate on a directory with existing expected output
    Given a file named "rcomp/tests/dir/test1.test" with:
      """
      ABC

      """
    Given a file named "rcomp/tests/dir/subdir/test2.test" with:
      """
      DEF

      """
    Given a file named "rcomp/expected/dir/test1.out" with:
      """
      GHI

      """
    When I run `rcomp generate dir`
    Then the output should contain "2 files (1 skipped, 1 generated)"
    And the output should contain "Run rcomp generate -O PATH"
    And the file "rcomp/expected/dir/test1.out" should contain "GHI"
    And the exit status should be 0
  
  @basic-config
  Scenario: Generate on directory with expected and overwrite
    Given a file named "rcomp/tests/dir/test1.test" with:
      """
      ABC

      """
    Given a file named "rcomp/tests/dir/subdir/test2.test" with:
      """
      DEF

      """
    Given a file named "rcomp/expected/dir/test1.out" with:
      """
      GHI

      """
    When I run `rcomp generate -O dir`
    Then the output should contain "2 files (2 generated)"
    And the file "rcomp/expected/dir/test1.out" should contain "ABC"
    And the exit status should be 0
