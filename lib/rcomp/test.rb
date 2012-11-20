module RComp
  class Test

    include RComp::Path

    attr_reader :test_path, :result_out_path, :result_err_path,
                :expected_out_path, :expected_err_path, :relative_path

    attr_accessor :result

    # Initialize a new Test
    #
    # path - The absolute path to the test
    #
    # Stores relative path, paths to expected and result out/err and 
    # defaults result to :skipped
    def initialize(path)
      @result = :skipped
      @relative_path = rel_path(path)
      @test_path = path
      @result_out_path = result_path(path, :out)
      @result_err_path = result_path(path, :err)
      @expected_out_path = expected_path(path, :out)
      @expected_err_path = expected_path(path, :err)
    end
  end
end
