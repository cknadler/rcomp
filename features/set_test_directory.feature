Feature: Set Test Directory Path
  In order to store test results
  As a user I should be able to set a path
  rcomp should store test files at that path

  Scenario: Set path
    When I run `rcomp -d spec/dir`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "tests_directory: spec/dir"
    And the exit status should be 0

  Scenario: Path already exists
    When I run `rcomp -d spec/dir`
    And I run `rcomp -d spec/dir2`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "tests_directory: spec/dir"
    And the stdout should contain "path exists"
    And the exit status should be 1

  Scenario: Overwrite path that already exists
    When I run `rcomp -d spec/dir`
    And I run `rcomp -d -O spec/dir2`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "tests_directory: spec/dir2"
    And the exit status should be 0
