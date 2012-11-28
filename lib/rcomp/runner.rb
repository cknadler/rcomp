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

      reporter.header

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
      test.expected_out_exists? || test.expected_err_exists?
    end

    # Test or generate output for a specified test
    #
    # test - A Test object
    # generate - Flag for running generate. Runs test otherwise.
    #
    # Returns nothing
    def run_test(test, generate=false)
      # Create output path if it doens't exist
      generate ? mkpath_to(test.expected_out_path) :
        mkpath_to(test.result_out_path)

      # Create process and run
      # Handle the difference in path between a test and generate process
      cmd = [@conf.command, test.test_path]
      out = generate ? test.expected_out_path : test.result_out_path
      err = generate ? test.expected_err_path : test.result_err_path
      process = Process.new(cmd, @conf.timeout, out, err)
      process.run

      if process.timedout?
        test.result = :timedout
        return
      end

      test.result = generate ? :success : cmp_output(test) 
    end

    # Compare the result and expected output of a test that has been run
    #
    # test - A Test object that has been run
    # precondition :: expected_exists?(test) is true
    #
    # Returns success or failure as a symbol
    def cmp_output(test)
      # test out and err
      if test.expected_out_exists? && test.expected_err_exists?
        cmp_out(test)
        cmp_err(test)
        return :success if (test.out_result && test.err_result)

      # test only out
      elsif test.expected_out_exists?
        cmp_out(test)
        return :success if test.out_result

      # test only err
      else
        cmp_err(test)
        return :success if test.err_result
      end

      return :failed
    end

    # Compare a tests expected and result stdout
    # Sets the result of the comparison to out_result in the test
    #
    # test - A test object that has been run
    #
    # Returns nothing
    def cmp_out(test)
      test.out_result = FileUtils.cmp(test.expected_out_path, 
                                      test.result_out_path)
    end

    # Compare a tests expected and result stderr
    # Sets the result of the comparison to err_result in the test
    #
    # test - A test object that has been run
    #
    # Returns nothing
    def cmp_err(test)
      test.err_result = FileUtils.cmp(test.expected_err_path,
                                      test.result_err_path)
    end
  end
end
