require 'fileutils'

module RComp
  module Runner

    include RComp::Actions
    
    # Run a suite of tests
    #
    # suite - An Array of Test objects
    # type - The type (Symbol) of the suite
    # options - A Hash of runner options
    #
    # Returns nothing
    def run_suite(suite, type, options={})
      @conf = Conf.instance
      reporter = Reporter.new(type)

      suite.each do |test|
        case type
        when :test
          if expected_exists?(test)
            run_test(test)
          end

        when :generate
          if expected_exists?(test)
            run_generate(test) if options[:overwrite]
          else
            run_generate(test)
          end
        end

        reporter.report(test)
      end

      reporter.summary
    end


    private

    # Check the existance of expected out/err for a test
    #
    # test - A Test object
    #
    # Returns a boolean
    def expected_exists?(test)
      File.exists?(test.expected_out_path) ||
        File.exists?(test.expected_err_path)
    end

    # Run a test storing it's result out and err
    #
    # test - A Test object
    #
    # Returns nothing
    def run_test(test)
      mkpath_to test.result_out_path
      mkpath_to test.result_err_path
      system "#{@conf.command} #{test.test_path} > #{test.result_out_path} 2> #{test.result_err_path}"
      test.result = compare_output(test) 
    end

    # Generate expected output for a test
    #
    # test - A Test object
    #
    # Returns nothing
    def run_generate(test)
      mkpath_to test.expected_out_path
      mkpath_to test.expected_err_path
      system "#{@conf.command} #{test.test_path} > #{test.expected_out_path} 2> #{test.expected_err_path}"
      test.result = :success
    end

    # Compare the result and expected output of a test that has been run
    #
    # test - A Test object that has been run
    # precondition: expected_exists?(test) is true
    #
    # Returns a Symbol, :success or :failure, conditionally if the test passed
    def compare_output(test)
      exp_out_exists = File.exists?(test.expected_out_path)
      exp_err_exists = File.exists?(test.expected_err_path)

      if exp_out_exists && exp_err_exists # test out and err
        if FileUtils.identical?(test.expected_out_path, test.result_out_path) &&
          FileUtils.identical?(test.expected_err_path, test.result_err_path)
          return :success
        end
      elsif exp_out_exists # test only out
        if FileUtils.identical?(test.expected_out_path, test.result_out_path)
          return :success
        end
      else # test only err
        if FileUtils.identical?(test.expected_err_path, test.result_err_path)
          return :success
        end
      end
      return :failed
    end
  end
end
