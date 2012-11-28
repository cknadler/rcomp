require 'find'

module RComp
  module Suite

    extend self
    extend Path

    @@conf = Conf.instance

    # Create a test suite
    #
    # pattern - A pattern to filter the tests that are added to the suite
    #
    # Returns an Array of Test objects
    def load(pattern=nil)
      tests = []

      # Find all tests in the tests directory
      Find.find @@conf.test_root do |path|
        # recurse into all subdirectories
        next if File.directory? path

        # filter tests by pattern if present
        if pattern
          next unless rel_path(path).match(pattern)
        end

        # ignore dotfiles
        next if File.basename(path).match(/^\..*/)

        # ignore files in ignore filter
        next if ignored?(path)

        tests << Test.new(path)
      end

      return tests
    end

    private

    # Checks all ignore patterns against a given relative path
    #
    # path - A relative path of a test
    #
    # Returns true if any patterns match the path, false otherwise
    def ignored?(path)
      @@conf.ignore.each do |ignore|
        return true if rel_path(path).match(ignore)
      end
      return false
    end
  end
end
