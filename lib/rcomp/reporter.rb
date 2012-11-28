module RComp
  class Reporter

    include RComp::Helper

    GEN_PADDING = ' ' * 1
    TEST_PADDING = ' ' * 3

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
          puts "passed : #{test.relative_path}"
        else
          puts "generated : #{test.relative_path}"
        end
        @success << test

      when :skipped
        puts "skipped : #{test.relative_path}"
        @skipped << test

      when :failed
        puts "failed : #{test.relative_path}"
        @failed << test

      when :timedout
        puts "timeout : #{test.relative_path}"
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
