module RComp
  class Reporter

    include RComp::Helper

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

    def report(test)
      case test.result
      # success
      when :success
        if @type == :test
          puts "\tpassed : #{test.relative_path}"
        else
          puts "\tgenerated : #{test.relative_path}"
        end
        @success += 1

      # skipped
      when :skipped
        puts "\tskipped : #{test.relative_path}"
        @skipped += 1

      # failed
      when :failed
        puts "\tfailed : #{test.relative_path}"
        @failed += 1

      # timedout
      when :timedout
        puts "\ttimeout : #{test.relative_path}"
        @failed += 1
      end
    end

    def summary
      print_summary
      exit 1 if @failed > 0
    end

    private

    def print_summary
      desc = []
      tests = @failed + @skipped + @success

      summary = "#{plural(tests, @type == :test ? 'test' : 'file')} ("

      desc << "#{@failed} failed" unless @failed == 0
      desc << "#{@skipped} skipped" unless @skipped == 0
      if @success != 0
        desc << "#{@success} #{@type == :test ? 'passed' : 'generated'}" 
      end

      summary += desc.join(", ") + ")"

      puts summary
    end
  end
end
