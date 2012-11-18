# stdlib
require 'find'

# internal
require 'rcomp/conf'
require 'rcomp/test'

class RComp
  module Suite

    # Create a test suite
    #
    # pattern - A pattern to filter the tests that are added to the suite
    #
    # Returns an Array of Test objects
    def load_suite(pattern='')
      tests = []

      # Find all tests in the tests directory
      Find.find Conf.instance.test_root do |path|
        # recurse into all subdirectories
        next if File.directory? path

        # filter tests by pattern if present
        unless pattern.empty?
          next unless rel_path(path).match(pattern)
        end

        tests << Test.new(path)
      end

      tests
    end
  end
end
