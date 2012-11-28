require 'fileutils'

module RComp
  module Runner

    extend self
    extend Actions
    
    # Run a suite of tests
    #
    # suite - An Array of Test objects
    # type - The type (Symbol) of the suite
    # options - A Hash of runner options
    #
    # Returns nothing
    def run(suite, type, options={})
      @conf = Conf.instance
      reporter = Reporter.new(type)

      suite.each do |test|
        case type
        when :test
          run_test(test) if expected_exists?(test)

        when :generate
          if expected_exists?(test)
            run_test(test, true) if options[:overwrite]
          else
            run_test(test, true)
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

    # Test or generate output for a specified test
    #
    # test - A Test object
    # generate - Flag for running generate. Runs test otherwise.
    #
    # Returns nothing
    def run_test(test, generate=false)
      generate ? mkpath_to(test.expected_out_path) :
        mkpath_to(test.result_out_path)

      # Create process and run
      cmd = [@conf.command, test.test_path]
      out = generate ? test.expected_out_path : test.result_out_path
      err = generate ? test.expected_err_path : test.result_err_path
      process = Process.new(cmd, @conf.timeout, out, err)
      process.run

      if process.timedout?
        test.result = :timedout
      else
        test.result = generate ? :success : compare_output(test) 
      end
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
