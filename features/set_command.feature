Feature: Set Command
  A user should be able to set the command RComp tests with from the CLI

  @announce
  Scenario: Set command
    When I run `rcomp set-command ./test_exec`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "command: ./test_exec"
    And the exit status should be 0

  @announce
  Scenario: Set command alias
    When I run `rcomp c ./test_exec`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "command: ./test_exec"
    And the exit status should be 0

  @announce
  Scenario: Overwrite command
    When I run `rcomp c ./first`
    And I run `rcomp c ./second`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "command: ./second"
    And the exit status should be 0
