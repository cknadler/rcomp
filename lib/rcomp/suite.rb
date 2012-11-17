class RComp
  # internal
  require 'rcomp/conf'

  class Suite
    attr_reader :tests

    # Initialize a new test suite. 
    #
    # path - The path to a file containing tests or a specific test
    def initialize(path=nil)

      # load Conf singleton
      @conf = Conf.instance

      @tests = path ? load_tests(path) : load_all_tests
    end

    private

    # Load tests from file structure
    #
    # Loads every file present at specified path and below 
    # into Test objects
    #
    # path - relative path to tests
    #
    # Returns an Array of Test objects
    def load_tests(path)
      root_path = path ? path : @config.test_root
    end

    # Load all tests from file structure
    #
    # Loads every test file into Test objects
    #
    # Returns an Array of Test objects
    def load_all_tests

    end
  end
end
