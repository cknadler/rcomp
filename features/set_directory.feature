Feature: Set Directory
  A user should be able to set the directory that RComp
  stores tests in from the CLI

  Scenario: Set directory
    When I run `rcomp set-directory spec/rcomp`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "directory: spec/rcomp"
    And the exit status should be 0

  Scenario: Set directory alias
    When I run `rcomp d spec/rcomp`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "directory: spec/rcomp"
    And the exit status should be 0

  Scenario: Overwrite directory
    When I run `rcomp d first`
    And I run `rcomp d second`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "directory: second"
    And the exit status should be 0
