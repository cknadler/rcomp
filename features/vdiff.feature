Feature: VDiff
  A user should be able vimdiff the expected and result file of a test

  @basic-config
  Scenario: VDiff without test
    When I run `rcomp vdiff test1.test`
    Then the output should contain "No test"
    And the exit status should be 1

  @basic-config
  Scenario: VDiff without result
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    When I run `rcomp vdiff test1.test`
    Then the output should contain "No result for test"
    And the exit status should be 1

  @basic-config
  Scenario: VDiff without expected
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    Given a file named "rcomp/results/test1.out" with:
      """
      ABC

      """
    When I run `rcomp vdiff test1.test`
    Then the output should contain "No expected output for test"
    And the exit status should be 1

  @basic-config
  Scenario: VDiff with expected and result
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    Given a file named "rcomp/results/test1.out" with:
      """
      ABC

      """
    And a file named "rcomp/expected/test1.out" with:
      """
      ABC

      """
    When I run `rcomp vdiff test1.test` interactively
    And I type "ZZZZ"
    Then the exit status should be 0
