Feature: Init
  In order to store tests
  RComp requires a directory structure
  if all configuration is complete
  RComp should create this when init is run

  Scenario: Valid init
    Given a directory named "spec"
    And I run `rcomp -d spec/rcomp`
    When I run `rcomp init`
    Then the following directories should exist:
      | spec/rcomp |
      | spec/rcomp/tests |
      | spec/rcomp/results |
      | spec/rcomp/expected |
    And the stdout should contain "successfully initialized"
    And the exit status should be 0

  Scenario: Init without directory set
    When I run `rcomp init`
    Then the stdout should contain "No test directory"
    And the exit status should be 1

  Scenario: Init with invalid directory
    Given a file named ".rcomp" with:
      """
      ---
      tests_directory: spec/rcomp
      """
    When I run `rcomp init`
    Then the stdout should contain "No directory"
    And the exit status should be 1

  Scenario: Already initialized
    Given a directory named "spec"
    And I run `rcomp -d spec`
    And I run `rcomp init`
    When I run `rcomp init`
    Then the stdout should contain "already initialized"
    And the exit status should be 1

