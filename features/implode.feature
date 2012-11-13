Feature: Implode
  A user should be able to nuke their RComp files from orbit

  @basic-config
  Scenario: Implode with basic config
    When I run `rcomp implode` interactively
    And I type "Y"
    Then a file named "rcomp" should not exist
    And the output should contain "imploded"
    And the exit status should be 0

  @basic-config
  Scenario: Implode with basic config and dont confirm
    When I run `rcomp implode` interactively
    And I type "N"
    Then a file named "rcomp" should exist
    And the output should contain "Aborting"
    And the exit status should be 1

