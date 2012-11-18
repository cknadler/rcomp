# internal
require 'rcomp/test'
require 'rcomp/helper'

class RComp
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
        case @type
        when :test
          puts "\t passed : #{test.relative_path}"
        when :generate
          puts "\tgenerated : #{test.relative_path}"
        end
        @success += 1

      # skipped
      when :skipped
        case @type
        when :test
          puts "\tskipped : #{test.relative_path}"
        when :generate
          puts "\t  skipped : #{test.relative_path}"
        end
        @skipped += 1

      # failed
      when :failed
        case @type
        when :test
          puts "\t failed : #{test.relative_path}"
        end
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
      summary = "#{plural((@skipped + @success), 'file')} ("
      desc << "#{@skipped} skipped" unless @skipped == 0
      desc << "#{@success} generated" unless @success == 0
      summary += desc.join(", ") + ")"
      puts summary
    end
  end
end
