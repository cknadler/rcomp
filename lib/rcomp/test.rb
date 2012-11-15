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

      failed = skipped = passed = 0

      # Find all tests at tests path
      Find.find(path) do |p|
        if FileTest.directory? p
          next
        else
            result = generate ? exec_generate(p, overwrite) : exec_test(p)
            case result
            when :failed
              failed += 1
            when :skipped
              skipped += 1
            when :passed
              passed += 1
            end
        end
      end
     
      if generate
        print_generate_footer skipped, passed
      else
        print_test_footer failed, skipped, passed
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
      return print_test_skipped rel_path unless File.exists? expected

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
        return print_generate_skipped(rel_path) unless overwrite
      else
        mkpath_to expected 
      end

      system "#{executable_path} #{test_path} > #{expected}"
      print_generate_success rel_path
    end

    # Test output

    def print_test_skipped(path)
      say "\tskipped : #{path}", :yellow
      return :skipped
    end

    def print_test_passed(path)
      say "\t passed : #{path}", :green
      return :passed
    end

    def print_test_failed(path)
      say "\t failed : #{path}", :red
      return :failed
    end

    def print_test_missing(path)
      rel_path = path.gsub(tests_path, '')
      say "No test at #{rel_path}", :red
      exit 1
    end
    
    def print_generate_success(path)
      say "\tgenerated : #{path}", :green
      return :passed
    end

    def print_generate_skipped(path)
      say "\t  skipped : #{path}", :yellow
      return :skipped
    end


    def print_test_footer(failed, skipped, passed)
      desc = []
      footer = "#{plural((failed + skipped + passed), 'test')} ("
      desc << "#{failed} failed" unless failed == 0
      desc << "#{skipped} skipped" unless skipped == 0
      desc << "#{passed} passed" unless passed == 0
      footer += desc.join(", ") + ")"
      say footer
    end

    def print_generate_footer(skipped, generated)
      desc = []
      footer = "#{plural((skipped + generated), 'file')} ("
      desc << "#{skipped} skipped" unless skipped == 0
      desc << "#{generated} generated" unless generated == 0
      footer += desc.join(", ") + ")"
      say footer

      if skipped > 0
        say "Run rcomp generate -O PATH to overwrite existing expected"
      end
    end
  end
end
