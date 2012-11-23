Feature: Init
  A user should be able to initialize the RComp's test directories

  Scenario: Blind init
    When I run `rcomp init` interactively
    And I type "./something"
    Then the following directories should exist:
      | rcomp |
      | rcomp/tests |
      | rcomp/results |
      | rcomp/expected |
    And the file ".rcomp" should contain "command: ./something"
    And the exit status should be 0

  Scenario: Init with directory set in project root
    Given a file named ".rcomp" with:
      """
      directory: dir

      """
    When I run `rcomp init` interactively
    And I type "./something"
    Then the following directories should exist:
      | dir |
      | dir/tests |
      | dir/results |
      | dir/expected |
    And the file ".rcomp" should contain "command: ./something"
    And the exit status should be 0

  Scenario: Init with directory set in subdirectory that exists
    Given a directory named "spec/dir"
    And a file named ".rcomp" with:
      """
      directory: spec/dir/rcomp

      """
    When I run `rcomp init` interactively
    And I type "./something"
    Then the following directories should exist:
      | spec/dir/rcomp |
      | spec/dir/rcomp/tests |
      | spec/dir/rcomp/results |
      | spec/dir/rcomp/expected |
    And the file ".rcomp" should contain "command: ./something"
    And the exit status should be 0
  
  Scenario: Init with directory set in subdirectory that doesn't exist
    Given a file named ".rcomp" with:
      """
      directory: spec/dir/rcomp

      """
    When I run `rcomp init` interactively
    And I type "./something"
    Then the following directories should exist:
      | spec/dir/rcomp |
      | spec/dir/rcomp/tests |
      | spec/dir/rcomp/results |
      | spec/dir/rcomp/expected |
    And the file ".rcomp" should contain "command: ./something"
    And the exit status should be 0

  @basic-conf
  Scenario: Already initialized
    When I run `rcomp init`
    Then the output should contain "already initialized"
    And the exit status should be 1
