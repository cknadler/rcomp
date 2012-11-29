module RComp
  class Test

    include RComp::Path

    attr_reader :test_path, :result_out_path, :result_err_path,
                :expected_out_path, :expected_err_path, :relative_path,
                :formatted_path

    attr_accessor :result, :out_result, :err_result

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
      @result_out_path = get_path(:result, path, '.out')
      @result_err_path = get_path(:result, path, '.err')
      @expected_out_path = get_path(:expected, path, '.out')
      @expected_err_path = get_path(:expected, path, '.err')
      @formatted_path = format_path(@relative_path)
    end

    def expected_out_exists?
      @expected_out_exists ||= File.exists?(@expected_out_path)
    end

    def expected_err_exists?
      @expected_err_exists ||= File.exists?(@expected_err_path)
    end

    private

    def get_path(type, test_path, extension)
      cmpnts = []
      if type == :result
        cmpnts << Conf.instance.result_root
      else
        cmpnts << Conf.instance.expected_root
      end
      cmpnts << rel_path(File.dirname(test_path))
      cmpnts << File.basename(test_path, ".*") + extension
      File.join(cmpnts)
    end

    # Formats relative path for user output
    #
    # path - A relative test path
    #
    # Returns formatted path
    def format_path(path)
      path[1..-1]
    end
  end
end
