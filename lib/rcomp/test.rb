class RComp
  module Test

    ##
    # Runs all tests at a given path.
    #
    # If the path is a directory it will run all tests contained
    # in that directory recursively.
    #
    # Can be passed the generate flag to put test results in
    # expected output instead of result.
    #
    # Can also be passed the overwrite flag which is only relevant
    # when generate is true. This will overwrite the existing expected
    # output for the specified test.
    
    def run_tests(path, generate=false, overwrite=false)

      success = failed = 0

      # Find all tests at tests path
      Find.find(path) do |p|
        if FileTest.directory? p
          next
        else
          # Run generate or test depending on the generate flag
          (generate ? exec_generate(p, overwrite) : exec_test(p)) ? 
            success += 1 : failed += 1
        end
      end
     
      if (success + failed) > 1
        if generate
          print_generate_footer success, failed
        else
          print_test_footer success, failed
        end
      end

      exit 1 if failed > 0
    end

    private

    ##
    # Runs a single test at specified path
    # Returns true if test passed, false otherwise
    # Will return false for a test run without expected output

    def exec_test(test_path)

      # Get required paths
      rel_path = relative_path test_path
      expected = output_path(expected_root_path + rel_path)
      result = output_path(result_root_path + rel_path)
      
      # Make sure expected output exists
      return print_test_stubbed rel_path unless File.exists? expected

      mkpath_to result unless File.exists? result
        
      system "#{executable_path} #{test_path} > #{result}"

      FileUtils.identical?(expected, result) ? 
        print_test_passed(rel_path) : print_test_failed(rel_path)
    end

    ##
    # Generate expected output for a single test at specified path
    # Returns true if generation was successful, false otherwise

    def exec_generate(test_path, overwrite)

      # Get required paths
      rel_path = relative_path test_path
      expected = output_path(expected_root_path + rel_path)

      # Handle overwriting
      if File.exists? expected
        return print_generate_exists rel_path unless overwrite
      else
        mkpath_to expected 
      end

      system "#{executable_path} #{test_path} > #{expected}"
      print_generate_success rel_path
    end

    # Test output

    def print_test_stubbed(path)
      say "Missing expected output for #{path}", :yellow
      return false
    end

    def print_test_passed(path)
      say "Test #{path} passed", :green
      return true
    end

    def print_test_failed(path)
      say "Test #{path} failed", :red
      return false
    end

    def print_test_missing(path)
      rel_path = path.gsub(tests_path, '')
      say "No test at #{rel_path}", :red
      exit 1
    end
    
    def print_generate_success(path)
      say "Generated expected output at #{path}", :green
      return true
    end

    def print_generate_exists(path)
      say "Expected output already exists at #{path}", :yellow
      return false
    end


    def print_test_footer(passed, failed)
      say "Ran #{passed + failed} tests"
      say "Failed #{plural failed, 'test'}" unless failed == 0
      say "Passed #{plural passed, 'test'}" unless passed == 0
    end

    def print_generate_footer(success, failed)
      say "Ran generate on #{success + failed} tests"

      unless failed == 0
        say "Failed generating output for #{plural failed, 'test'}"
      end

      unless success == 0
        say "Expected output was generated for #{plural success, 'test'}"
      end

      if failed > 0
        say "Run rcomp gen -O PATH to overwrite existing expected output"
      end
    end
  end
end
