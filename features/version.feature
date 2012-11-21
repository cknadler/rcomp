Feature: Version
  A user should be able to find out RComp's version number

  Scenario: run version
    When I run `rcomp version`
    Then the output should contain the version number
