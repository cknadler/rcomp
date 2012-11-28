module RComp
  class Reporter

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
      @success = []
      @skipped = []
      @failed = []
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
        @success << test

      when :skipped
        if @type == :test
          print_test_skipped(test)
        else
          print_generate_skipped(test)
        end
        @skipped << test

      # Generate can't fail directly
      when :failed
        print_test_failed(test)
        @failed << test

      when :timedout
        if @type == :test
          print_test_timeout(test)
        else
          print_generate_timeout(test)
        end
        @failed << test
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
      exit 1 if @failed.size > 0
    end

    private

    def print_test_success(test)
      puts "passed : ".rjust(TEST_JUSTIFY) + test.relative_path
    end

    def print_generate_success(test)
      puts "generated : ".rjust(GEN_JUSTIFY) + test.relative_path
    end

    def print_test_skipped(test)
      puts "skipped : ".rjust(TEST_JUSTIFY) + test.relative_path
    end

    def print_generate_skipped(test)
      puts "skipped : ".rjust(GEN_JUSTIFY) + test.relative_path
    end

    def print_test_failed(test)
      puts "failed : ".rjust(TEST_JUSTIFY) + test.relative_path
    end

    def print_test_timeout(test)
      puts "timeout : ".rjust(TEST_JUSTIFY) + test.relative_path
    end

    def print_generate_timeout(test)
      puts "timeout : ".rjust(GEN_JUSTIFY) + test.relative_path
    end

    def print_summary
      desc = []
      tests = @failed.size + @skipped.size + @success.size

      summary = "#{plural(tests, @type == :test ? 'test' : 'file')} ("

      desc << "#{@failed.size} failed" unless @failed.empty?
      desc << "#{@skipped.size} skipped" unless @skipped.empty?
      unless @success.empty?
        desc << "#{@success.size} #{@type == :test ? 'passed' : 'generated'}" 
      end

      summary += desc.join(", ") + ")"

      puts "\n" + summary
    end
  end
end
