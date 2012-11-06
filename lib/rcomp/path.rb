class RComp
  module Path

    ##
    # Finds the first occurance of a file having the inputed relative path
    # Returns the absolute path to the file

    def find_test_path(path)

      absolute_path = test_root_path + path
      
      # Special case where full path is provided
      return absolute_path if File.exists? absolute_path
      
      # If the path cannot be found directly
      # search for the path without extension
      Find.find File.dirname(absolute_path) do |p|
        if File.basename(p, '.*') == File.basename(path)
          return p
        end
      end

      # Test not found
      say "No test at #{path}"
      exit 1
    end

    ##
    # Returns the coresponding output path given the path to a test.
    # output_path('notes/t1.mt') # => 'notes/t1.out'
    
    def output_path(path)
      File.dirname(path) + '/' + File.basename(path, '.*') + '.out'
    end

    def relative_path(path)
      path.gsub(test_root_path, '')
    end

    # Path getters

    def conf_path
      @conf_path ||= '.rcomp'
    end

    def root_path
      @conf["tests_directory"]
    end

    def set_root_path(path)
      @conf["tests_directory"] = path
    end

    def test_root_path
      @test_root_path ||= root_path + '/tests/'
    end

    def expected_root_path
      @expected_root_path ||= root_path + '/expected/'
    end

    def result_root_path
      @result_root_path ||= root_path + '/results/'
    end

    def executable_path
      @conf["executable"]
    end

    def set_executable_path(path)
      @conf["executable"] = path
    end
  end
end
