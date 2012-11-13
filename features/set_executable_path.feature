Feature: Set Executable
  In order to test an executable
  rcomp needs a valid path to it
  As a user I should be able to set that path

  Scenario: Set path
    When I run `rcomp -e test_exec`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "executable: test_exec"
    And the exit status should be 0

  Scenario: Path already exists
    When I run `rcomp -e test_exec`
    And I run `rcomp -e test_exec2`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "executable: test_exec"
    And the stdout should contain "already exists"
    And the exit status should be 1

  Scenario: Overwrite path that already exists
    When I run `rcomp -e test_exec`
    And I run `rcomp -e -O test_exec2`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "executable: test_exec2"
    And the exit status should be 0
