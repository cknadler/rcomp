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
      case @type
      when :test
        print_test_summary
      when :generate
        print_generate_summary
      end
      exit 1 if @failed > 0
    end

    private

    def print_test_summary
      desc = []
      summary = "#{plural((@failed + @skipped + @success), 'test')} ("
      desc << "#{@failed} failed" unless @failed == 0
      desc << "#{@skipped} skipped" unless @skipped == 0
      desc << "#{@success} passed" unless @success == 0
      summary += desc.join(", ") + ")"
      puts summary
    end

    def print_generate_summary
      desc = []
      summary = "#{plural((@failed + @skipped + @success), 'file')} ("
      desc << "#{@failed} failed" unless @failed == 0
      desc << "#{@skipped} skipped" unless @skipped == 0
      desc << "#{@success} generated" unless @success == 0
      summary += desc.join(", ") + ")"
      puts summary
    end
  end
end
