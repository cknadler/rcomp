Feature: Test All
  A user should be able to run all tests with a single command

  @basic-config
  Scenario: Test all with multiple valid tests in directories
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/tests/dir/test2.test" with:
      """
      DEF

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      ABC

      """
    And a file named "rcomp/expected/dir/test2.out" with:
      """
      DEF

      """
    When I run `rcomp test-all`
    Then the output should contain "2 tests (2 passed)"
    And the file "rcomp/results/test1.out" should contain "ABC"
    And the file "rcomp/results/dir/test2.out" should contain "DEF"
    And the exit status should be 0

  @basic-config
  Scenario: Test all with passing, failing and skipped tests
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/tests/test2.test" with:
      """
      DEF

      """
    And a file named "rcomp/tests/test3.test" with:
      """
      XYZ

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test2.out" with:
      """
      GHI

      """
    When I run `rcomp test-all`
    Then the output should contain "3 tests (1 failed, 1 skipped, 1 passed)"
    And the file "rcomp/results/test1.out" should contain "ABC"
    And the file "rcomp/results/test2.out" should contain "DEF"
    And the exit status should be 1
