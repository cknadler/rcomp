require 'thor'

module RComp
  class Reporter

    include Thor::Shell
    include RComp::Helper

    PADDING = 4
    GEN_JUSTIFY = 12 + PADDING
    TEST_JUSTIFY = 10 + PADDING

    # Initialize a new Reporter
    #
    # type - The type (Symbol) of the suite
    #
    # Initialize counters for all result types
    def initialize(type)
      @type = type
      @success = 0
      @skipped = 0
      @failed = 0
    end

    # Main interface for reporting
    # Reports the result of a single test or generation
    #
    # test - A test object that has been run
    #
    # Returns nothing
    def report(test)
      case test.result
      when :success
        if @type == :test
          print_test_success(test)
        else
          print_generate_success(test)
        end
        @success += 1

      when :skipped
        if @type == :test
          print_test_skipped(test)
        else
          print_generate_skipped(test)
        end
        @skipped += 1

      # Generate can't fail directly
      when :failed
        print_test_failed(test)
        @failed += 1

      when :timedout
        if @type == :test
          print_test_timeout(test)
        else
          print_generate_timeout(test)
        end
        @failed += 1
      end
    end

    # Prints header for test suite report
    #
    # Returns nothing
    def header
      # The suite is a test suite
      if @type == :test
        puts "RComp: running test suite..."

      # The suite is a generation suite
      else
        puts "RComp: generating expected output..."
      end
      puts
    end

    # Prints summary of test suite report
    #
    # Returns nothing
    def summary
      print_summary
      exit 1 if @failed > 0
    end

    private

    def print_test_success(test)
      say "passed : ".rjust(TEST_JUSTIFY) + test.relative_path, :green
    end

    def print_generate_success(test)
      say "generated : ".rjust(GEN_JUSTIFY) + test.relative_path, :green
    end

    def print_test_skipped(test)
      say "skipped : ".rjust(TEST_JUSTIFY) + test.relative_path, :yellow
    end

    def print_generate_skipped(test)
      say "skipped : ".rjust(GEN_JUSTIFY) + test.relative_path, :yellow
    end

    def print_test_failed(test)
      msg = "failed : ".rjust(TEST_JUSTIFY) + test.relative_path

      # both out and err present
      if test.expected_out_exists? && test.expected_err_exists?
        # failed both out and err cmp
        if !test.out_result && !test.err_result
          msg += " (out, err)"

        # failed out cmp
        elsif !test.out_result
          msg += " (out)"

        # failed err cmp
        else
          msg += " (err)"
        end

      # out present
      elsif test.expected_out_exists?
        msg += " (out)"

      # err present
      else
        msg += " (err)"
      end

      say msg, :red
    end

    def print_test_timeout(test)
      say "timeout : ".rjust(TEST_JUSTIFY) + test.relative_path, :red
    end

    def print_generate_timeout(test)
      say "timeout : ".rjust(GEN_JUSTIFY) + test.relative_path, :red
    end

    def print_summary
      # print skipped explanation if anything was skipped
      if @skipped > 0
        if @type == :test
          print_skipped_test_explanation
        else
          print_skipped_generate_explanation
        end
      end

      # construct and print output summary
      desc = []
      tests = @failed + @skipped + @success

      summary = "#{plural(tests, @type == :test ? 'test' : 'file')} ("

      desc << set_color("#{@failed} failed", :red) unless @failed == 0
      desc << set_color("#{@skipped} skipped", :yellow) unless @skipped == 0
      unless @success == 0
        if @type == :test
          desc << set_color("#{@success} passed", :green)
        else
          desc << set_color("#{@success} generated", :green)
        end
      end

      summary += desc.join(", ") + ")"
      puts "\n" + summary
    end

    def print_skipped_test_explanation
      say "\nSkipped #{plural(@skipped, 'test')} due to missing expected output"
      say "Run rcomp generate or manually create expected output"
    end

    def print_skipped_generate_explanation
      say "\nSkipped #{plural(@skipped, 'file')} due to existing expected output"
      say "Run rcomp generate -O to overwrite"
    end
  end
end
