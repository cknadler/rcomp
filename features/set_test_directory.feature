Feature: Set Test Directory Path
  In order to store test results
  As I I should be able to set a path
  rcomp should store test files at that path

  Scenario: Set path
    When I run `rcomp set-tests-directory spec/rcomp`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "tests_directory: spec/rcomp"
    And the exit status should be 0

  Scenario: Path already exists
    When I run `rcomp -d spec/rcomp`
    And I run `rcomp -d spec/something`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "tests_directory: spec/rcomp"
    And the stdout should contain "path exists"
    And the exit status should be 1

  Scenario: Overwrite path that already exists
    When I run `rcomp -d -O spec/rcomp`
    And I run `rcomp -d -O spec/something`
    Then a file named ".rcomp" should exist
    And the file ".rcomp" should contain "tests_directory: spec/something"
    And the exit status should be 0
