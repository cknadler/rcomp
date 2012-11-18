Feature: Init
  A user should be able to initialize the RComp's test directories

  Scenario: Blind init
    When I run `rcomp init`
    Then the following directories should exist:
      | rcomp |
      | rcomp/tests |
      | rcomp/results |
      | rcomp/expected |
    And the exit status should be 0

  Scenario: Init with directory set in project root
    Given I run `rcomp d dir`
    When I run `rcomp init`
    Then the following directories should exist:
      | dir |
      | dir/tests |
      | dir/results |
      | dir/expected |
    And the exit status should be 0

  Scenario: Init with directory set in subdirectory
    Given a directory named "spec/dir"
    And I run `rcomp d spec/dir/rcomp`
    When I run `rcomp init`
    Then the following directories should exist:
      | spec/dir/rcomp |
      | spec/dir/rcomp/tests |
      | spec/dir/rcomp/results |
      | spec/dir/rcomp/expected |
    And the exit status should be 0

  Scenario: Init with directory set in nonexistant subdirectory
    Given I run `rcomp d nonexistant/rcomp`
    When I run `rcomp init`
    Then the stdout should contain "No directory nonexistant"
    And the exit status should be 1

  Scenario: Already initialized
    Given I run `rcomp init`
    When I run `rcomp init`
    Then the stdout should contain "already initialized"
    And the exit status should be 1
