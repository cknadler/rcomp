Feature: Generate All
  A user should be able to run generate on all tests with a single command

  @basic-config
  Scenario: Generate all with valid tests
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/tests/dir/test2.test" with:
      """
      DEF

      """
    When I run `rcomp generate-all`
    Then the output should contain "2 files (2 generated)"
    And the file "rcomp/expected/test1.out" should contain "ABC"
    And the file "rcomp/expected/dir/test2.out" should contain "DEF"
    And the exit status should be 0

  @basic-config
  Scenario: Generate all with existing expected
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
      GHI

      """
    When I run `rcomp generate-all`
    Then the file "rcomp/expected/test1.out" should contain "GHI"
    And the file "rcomp/expected/dir/test2.out" should contain "DEF"
    And the output should contain "2 files (1 skipped, 1 generated)"
    And the exit status should be 0

  @basic-config
  Scenario: Generate all with existing expected and overwrite
    Given a file named "rcomp/tests/test1.test" with:
      """
      ABC

      """
    And a file named "rcomp/tests/dir/test2.test" with:
      """
      DEF

      """
    And a file named "rcomp/expected/test1.test" with:
      """
      GHI

      """
    When I run `rcomp generate-all -O` interactively
    And I type "Y"
    Then the output should contain "2 files (2 generated)"
    And the file "rcomp/expected/test1.out" should contain "ABC"
    And the file "rcomp/expected/dir/test2.out" should contain "DEF"
    And the exit status should be 0

  @basic-config
  Scenario: Generate all with existing expected and unconfirmed overwrite
    When I run `rcomp generate-all -O` interactively
    And I type "N"
    Then the output should contain "Aborting"
    And the exit status should be 1
